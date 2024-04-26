# RSSfeedPS1

This PowerShell script serves as an HTTP server capable of handling two endpoints: /rss/ and /rssitem/.

    /rss/:
        When receiving a GET request, it responds with an RSS feed in XML format.
        This endpoint serves as the main RSS feed.

    /rssitem/:
        When receiving a GET request, it responds with the latest RSS item in JSON format.
        When receiving a POST request with JSON data representing a new RSS item, it adds this item to the RSS feed.
        This endpoint allows retrieval and addition of individual RSS items.

The script also implements CORS (Cross-Origin Resource Sharing) to allow requests from different origins. It handles OPTIONS requests to ensure proper CORS preflight checks, allowing cross-origin requests to be made to the server.

Overall, this script provides a simple HTTP server for managing an RSS feed, making it suitable for various applications such as automated RSS feed updates or integration with other services like Grafana.
