const functions = require('firebase-functions');
const fetch = require('node-fetch');
const RSSParser = require('rss-parser');

exports.fetchRSSFeed = functions.https.onRequest(async (request, response) => {
    const rssParser = new RSSParser();
    const rssUrl = 'YOUR_RSS_FEED_URL';

    try {
        const res = await fetch(rssUrl);
        const xml = await res.text();
        const feed = await rssParser.parseString(xml);
        
        // Here you can store the feed in Firestore or Realtime Database
        // For example: admin.firestore().collection('feeds').add(feed);

        response.json(feed);
    } catch (error) {
        console.error("Error fetching RSS feed:", error);
        response.status(500).send('Error fetching RSS feed');
    }
});
