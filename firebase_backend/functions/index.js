const functions = require('firebase-functions');
const admin = require('firebase-admin'); //added for FCM
const fetch = require('node-fetch');
const cheerio = require('cheerio');
const RSSParser = require('rss-parser');

admin.initializeApp();

exports.fetchRSSFeedAndNotify = functions.https.onRequest(async (request, response) => {
    const rssParser = new RSSParser();
    const rssUrl = 'https://itch.io/games/free.xml';

    try {
        const res = await fetch(rssUrl);
        const xml = await res.text();
        const feed = await rssParser.parseString(xml);

        console.log('Fetched RSS Feed:', JSON.stringify(feed, null, 2));

        if (feed.items.length > 0) {
            const latestItem = feed.items[0]; // Assuming the first item is the latest
            console.log('Latest News Title:', latestItem.title);

            // Prepare and send a notification about the latest item
            const message = {
                notification: {
                    title: 'New Game Alert!',
                    body: `${latestItem.title} is now available on itch.io!`
                },
                topic: 'new-games'
            };

            await admin.messaging().send(message);
            console.log('Notification sent for:', latestItem.title);
        }

        response.json(feed);
    } catch (error) {
        console.error("Error fetching RSS feed or sending notification:", error);
        response.status(500).send('Failed to fetch RSS feed or send notification');
    }
});

exports.item_list = functions.https.onRequest(async (request, response) => {
    const xml2js = require('xml2js');
    const rssUrl = 'https://itch.io/';

    // Verifica che il metodo della richiesta sia POST
    if (request.method !== "GET") {
        response.status(400).send('Please send a GET request');
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

    // Esegui le elaborazioni sulla stringa di input
    const filters = request.body.filters || '';
    const type = request.body.type;

    const filteredUrl = rssUrl + type  + filters + '.xml'
    console.log(filteredUrl)

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
                response.status(400).send('Errore nel parsing del documento XML:', err);
                return;
            }

            items = result.rss.channel.item;            
            title = result.rss.channel.title

        });
    } catch (error) {
        response.status(400).send('Errore nella connessione con itch.io o url non corretto: "' + filteredUrl + '"\n' + error);
    }

    // Correzione dei vari parametri di ogni gioco
    if(type === 'games'){
        for(const game of items){
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

    // Crea un oggetto JSON con i risultati
    const result = {
        parsed_url: filteredUrl,
        title: title,
        item_type: type,
        items_size: items.length,
        items: items
    };

    // Restituisci l'oggetto JSON come risposta
    response.json(result);
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
