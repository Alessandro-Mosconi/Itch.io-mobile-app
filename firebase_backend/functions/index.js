const functions = require('firebase-functions');
const fetch = require('node-fetch');
const RSSParser = require('rss-parser');

exports.fetchRSSFeed = functions.https.onRequest(async (request, response) => {
    const rssParser = new RSSParser();
    const rssUrl = 'https://itch.io/games/free.xml';

    try {
        const res = await fetch(rssUrl);
        const xml = await res.text();
        const feed = await rssParser.parseString(xml);

        // Log the whole feed to the Firebase Functions log for debugging
        console.log('Fetched RSS Feed:', JSON.stringify(feed, null, 2));

        // Optionally, if you want to inspect specific parts:
        console.log('Feed Title:', feed.title);
        feed.items.forEach(item => {
            console.log('News Title:', item.title); // Example of how to log titles of items in the feed
        });

        // Respond with the entire feed JSON or part of it
        response.json(feed);
    } catch (error) {
        console.error("Error fetching RSS feed:", error);
        response.status(500).send('Error fetching RSS feed');
    }
});
