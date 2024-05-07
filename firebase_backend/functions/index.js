const functions = require('firebase-functions');
const admin = require('firebase-admin'); //added for FCM
const fetch = require('node-fetch');

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
