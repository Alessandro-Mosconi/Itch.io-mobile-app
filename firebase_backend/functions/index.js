const functions = require('firebase-functions');
const admin = require('firebase-admin'); //added for FCM
const fetch = require('node-fetch');
const cheerio = require('cheerio');
const RSSParser = require('rss-parser');
const axios = require('axios');
const { topic } = require('firebase-functions/v1/pubsub');

admin.initializeApp();
const db = admin.database();

// Scheduled trigger
exports.notifyFeedScheduled = functions.pubsub.schedule('every 2 hours').onRun(async (context) => {
    await notifyFeedCore();
});


// HTTPS trigger
exports.notifyFeedHttp = functions.https.onRequest(async (req, res) => {
    await notifyFeedCore();
    res.send('Notification feed processed.');
});

async function notifyFeedCore() {
    // Retrieve the list of topics to notify
    console.log("é partita")
    const topicsToNotify = await getTopics();

    for (const topic of topicsToNotify) {
        const newItems = await getNewItems(topic);
        if (newItems.items.length > 0) {
            console.log("sono dentro")
            await send_notification(newItems.title, topic.key, topic.type, newItems.items.length)
        }
        else{
            console.log("sono fuori")
        }
    }
}

async function getTopics() {
    const userSearchRef = db.ref('user_search');
    const userSearchSnapshot = await userSearchRef.once('value');
    const result = [];

    userSearchSnapshot.forEach(userSnapshot => {
      userSnapshot.forEach(searchSnapshot => {
        const searchData = searchSnapshot.val();
        if (searchData.notify === true) {
          result.push({
            key: searchSnapshot.key,
            type: searchData.type,
            filters: searchData.filters,
          });
        }
      });
    });
    return result;
}


async function getNewItems(topic) {
    // Get old items from the database (if there are any)
    const oldItemsSnapshot = await db.ref(`searches/${topic.key}`).once('value');
    const oldItems = oldItemsSnapshot.exists() ? oldItemsSnapshot.val() : [];
 
    // Fetch new items (simulating this as the getSearchResult function is not defined here)
    const newSearch = await getSearchResult(topic.type, topic.filters);

    if (newSearch.type === 'error') {
        return [];
    }

    const newItems = newSearch.content.items || [];

    // Create a set of URLs from old items for fast lookup
    const oldItemUrls = new Set(oldItems.map(item => item.link));

    // Find differences between old and new items based on the URL field
    const newUniqueItems = newItems.filter(item =>!oldItemUrls.has(item.link));
    // Update the database with the new items
    await db.ref(`searches/${topic.key}`).set(newItems.map(item => JSON.parse(JSON.stringify(item))));
    
    // Return the new unique items

    return { 
        "items": newUniqueItems,
        "title": newSearch.content.title
    };
}


async function send_notification(title,topicName,type,counts){
    console.log("mi preparo a mandare")
    // Prepare and send a notification about the latest item
    const message = {
            notification: {
                title: title + "Alert!",
                body: counts + " " + type
            },
            topic: topicName
    }
    await admin.messaging().send(message);
    console.log(message)
}


exports.item_list = functions.https.onRequest(async (request, response) => {

    // Verifica che il metodo della richiesta sia POST
    if (request.method !== "POST") {
        response.status(400).send('Please send a POST request');
        return;
    }

    // Verifica che il corpo della richiesta contenga una stringa
    if (!request.body) {
        response.status(400).send('Please provide a the request body');
        return;
    }
    if (request.body.filters && typeof request.body.filters !== 'string') {
        response.status(400).send('Please provide a correct filters filed type in request body');
        return;
    }

    if(!request.body.type ||  typeof request.body.type !== 'string') {
        response.status(400).send('Please provide an type field in the request body');
        return;
    }

    const result = await getSearchResult(request.body.type, request.body.filters || '');
    if (result.type === 'error') {
        response.status(400).send(result.message);
        return;
    } else {
        // Restituisci l'oggetto JSON come risposta
        response.json(result.content);
    }

});

exports.search = functions.https.onRequest(async (request, response) => {
    const searchUrl = 'https://itch.io/search?q=';

    // Ensure the request method is GET
    if (request.method !== "GET") {
        response.status(400).send('Please send a GET request');
        return;
    }

    // Ensure the query parameter 'search' is present
    const searchQuery = request.query.search;
    if (!searchQuery || typeof searchQuery !== 'string') {
        response.status(400).send('Please provide a valid search query');
        return;
    }

    // Encode the search query
    const search = encodeURIComponent(searchQuery);
    const filteredUrl = searchUrl + search;
    console.log(filteredUrl);

    let gamesData = [];
    let usersData = [];

    try {
        // Fetch the HTML content from the URL
        const res = await fetch(filteredUrl);

        // Ensure the request was successful
        if (!res.ok) {
            throw new Error('Error fetching HTML content');
        }

        // Get the HTML text from the response
        const html = await res.text();

        // Parse the HTML using Cheerio
        const $ = cheerio.load(html);

        // Select the div with class "game_grid_widget"
        const gameGrid = $('.game_grid_widget');

        // Ensure the div exists
        if (gameGrid.length > 0) {
            // Iterate over each game cell and extract data
            gameGrid.find('.game_cell').each(function () {
                const link = $(this).find('.game_title a').attr('href');
                const img = $(this).find('.game_thumb img').attr('data-lazy_src');
                const title = $(this).find('.game_title a').text();
                const text = $(this).find('.game_text').text();
                const author = $(this).find('.game_author a').text();

                // Create a JSON object for the current game
                const gameData = {
                    link: link,
                    imageurl: img,
                    title: title,
                    description: text,
                    author: author
                };

                // Add the JSON object to the games array
                gamesData.push(gameData);
            });
        }

        // Select the div with class "user_results_cells"
        const userResultsCells = $('.user_results_cells');

        // Ensure the div exists
        if (userResultsCells.length > 0) {
            // Iterate over each user result cell and extract data
            userResultsCells.find('.user_result_cell').each(function () {
                const userLink = $(this).find('.avatar_container').attr('href');
                const userImg = $(this).find('.result_avatar').css('background-image').replace(/url\(['"]?(.*?)['"]?\)/i, '$1');
                const userName = $(this).find('.user_name a').text();
                const numberOfProjects = $(this).find('.user_sub').text().trim().split(' ')[0];

                // Create a JSON object for the current user
                const userData = {
                    link: userLink,
                    img: userImg,
                    name: userName,
                    number_of_projects: numberOfProjects
                };

                // Add the JSON object to the users array
                usersData.push(userData);
            });
        }

    } catch (error) {
        response.status(400).send(`Error connecting to itch.io or invalid URL: "${filteredUrl}"\n${error}`);
        return;
    }

    // Create a JSON object with the results
    const result = {
        url: filteredUrl,
        games: gamesData,
        users: usersData
    };

    // Send the JSON object as the response
    response.json(result);
});

exports.get_saved_search_carousel = functions.https.onRequest(async (request, response) => {

    // Ensure the request method is GET
    if (request.method !== "POST") {
        response.status(400).send('Please send a POST request');
        return;
    }

    // Ensure the query parameter 'token' is present
    const token = request.body.token;
    if (!token || typeof token !== 'string') {
        response.status(400).send('Please provide a valid token');
        return;
    }

    const dataSnapshot = await db.ref('user_search/' + token).once('value');

    if (!dataSnapshot.exists()) {
        response.status(200).send('[]');
        return;
    }

    const result = dataSnapshot.val();

    let values = Object.values(dataSnapshot.val());
    const temp = await Promise.all(values.map(async value => {
        const result = await getSearchResult(value.type || 'games', value.filters || '');
        if(result.type === 'error') {
            response.status(400).send('Error in parsing research');
            return
        } else {
            return {
                type: value.type,
                filters: value.filters,
                notify: value.notify,
                items: result.content.items
            };
        }
    }));
    values = temp;

    // Send the JSON object as the response
    response.json(values);
});

exports.fetch_jams = functions.https.onRequest(async (request, response) => {

    if (request.method !== "GET") {
        response.status(400).send('Please send a GET request');
        return;
    }
    
    const includeDetailsParam = request.query.include_details;

    let includeDetails;
    if (includeDetailsParam === undefined) {
        includeDetails = false; 
    } else {
        includeDetails = includeDetailsParam.toLowerCase() === 'true';
    }

    const jams = await getJams();

    if(includeDetails){
        const promises = jams.map(oggetto => getJamDetail(oggetto.id));

        try {
            const details = await Promise.all(promises);
    
            details.forEach((detail, index) => {
                jams[index].detail = detail;
            });
    
        } catch (error) {
            console.error(`Errore durante il recupero dei dettagli: ${error.message}`);
        }
    }
    
    response.json(jams);
});

async function getJams() {
    const url = 'https://itch.io/jams';
    let jams = [];

    try {
        const response = await axios.get(url);
        const html = response.data;

        const $ = cheerio.load(html);
        
        const scriptTag = $('script[type="text/javascript"]').filter((i, el) => {
            return $(el).html().includes('R.Jam.FilteredJamCalendar');
        }).html();

        if (!scriptTag) {
            return res.status(404).send('JSON script tag not found');
        }

        const scriptContent = scriptTag;

        const jsonStartIndex = scriptContent.indexOf('R.Jam.FilteredJamCalendar(') + 'R.Jam.FilteredJamCalendar('.length;
        const jsonEndIndex = scriptContent.indexOf('), document.getElementById');

        const jsonString = scriptContent.substring(jsonStartIndex, jsonEndIndex).trim();

        const jsonObject = JSON.parse(jsonString);
        jams = jsonObject.jams;
;
    } catch (error) {
        console.error('Error extracting JSON:', error);
        res.status(500).send('Internal Server Error');
    }
    return jams;
}

async function getSearchResult(type, filters) {
    const xml2js = require('xml2js');
    const rssUrl = 'https://itch.io/';

    const filteredUrl = rssUrl + type + filters + '.xml';

    let items = [];
    let title = '';

    try {
        // Ottieni il feed RSS con fetch
        const res = await fetch(filteredUrl);
        const xmlData = await res.text();

        // Opzioni per il parsing
        const parserOptions = {
            trim: true,
            explicitArray: false
        };

        // Effettua il parsing del documento XML
        xml2js.parseString(xmlData, parserOptions, (err, result) => {
            if (err) {
                return {
                    type: 'error',
                    message: 'Errore nel parsing del documento XML:' + err
                };
            }

            items = result.rss.channel.item;
            title = result.rss.channel.title;

        });

    } catch (error) {
        return {
            type: 'error',
            message: 'Errore nella connessione con itch.io o url non corretto: "' + filteredUrl + '"\n' + error,
        };
    }

    // Correzione dei vari parametri di ogni gioco
    if (type === 'games') {
        for (const game of items) {
            const altRegex = /alt="(.*?)"/;
            // Espressione regolare per estrarre il valore dell'attributo src
            const srcRegex = /src="(.*?)"/;

            // Estrarre il testo tra le doppie virgolette per l'attributo alt
            const altMatch = altRegex.exec(game.description);
            const alt = altMatch ? altMatch[1] : '';

            // Estrarre il valore dell'attributo src
            const srcMatch = srcRegex.exec(game.description);
            const img = srcMatch ? srcMatch[1] : '';

            // Rimuovere il tag img dalla descrizione
            const cleanDescription = game.description.replace(/<img.*?>/, '').trim();

            game.alt = alt;
            game.img = img;
            game.oldDescription = game.description;
            game.description = cleanDescription;

            const [titleText, filtersText] = game.title.split(" [");

            const filters = filtersText.replace(/\]/g, '').split(' ').filter(filter => filter !== '');

            game.title = titleText;
            game.filters = filters;

            game.platforms = Object.keys(game.platforms).filter(key => game.platforms[key] === "yes");

        }
    }


    // Restituisci un oggetto JSON con i risultati
    return {
        type: 'success',
        content: {
            parsed_url: filteredUrl,
            title: title,
            item_type: type,
            items_size: items.length,
            items: items
        }
    };

}

async function getJamDetail(id) {
    try {
        const response = await axios.get(`https://itch.io/jam/${id}/entries.json`);
        return response.data;
    } catch (error) {
        //console.error(`Errore durante la richiesta per l'ID ${id}: ${error.message}`);
        return null;
    }
}

