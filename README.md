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

To add a new RSS item, you can follow these steps:

Clone the GitHub repository to your local machine.

    Edit the PowerShell Script:
        Open the PowerShell script in a text editor.
        Locate the Generate-RSSFeed function. This function generates the initial RSS feed with a sample item. You can modify this function to add your own initial RSS item if needed.
        Locate the /rssitem/ endpoint handling section. This section handles POST requests to add new RSS items. Ensure that the script is correctly parsing the JSON data from the POST request and adding it to the RSS feed.

    Run the Script: Run the PowerShell script on your local machine. Ensure that it is listening on the desired port (e.g., http://localhost:8080/rss/).

    Make a POST Request:
        Use a tool like cURL or Postman to make a POST request to http://localhost:8080/rssitem/ with JSON data representing the new RSS item.
        Example JSON data:

        json

        {
            "Title": "New RSS Item Title",
            "Description": "Description of the new RSS item.",
            "Link": "http://example.com/new_item",
            "PubDate": "2024-04-30T12:00:00Z"
        }

    Verify:
        After making the POST request, verify that the new RSS item has been successfully added to the RSS feed by making a GET request to http://localhost:8080/rss/ or http://localhost:8080/rssitem/.
        Ensure that the new item appears in the RSS feed data.



