# Function to create RSS feed item
function Create-RSSItem {
    param(
        [string]$Title,
        [string]$Description,
        [string]$Link,
        [datetime]$PubDate
    )

    $item = @"
    <item>
        <title><![CDATA[$Title]]></title>
        <description><![CDATA[$Description]]></description>
        <link>$Link</link>
        <pubDate>$PubDate</pubDate>
    </item>
"@

    return $item
}

# Function to handle OPTIONS request
function Handle-OptionsRequest {
    param(
        [System.Net.HttpListenerRequest]$request,
        [System.Net.HttpListenerResponse]$response
    )

    $response.Headers.Add("Access-Control-Allow-Origin", "*")  # Allow cross-origin requests
    $response.Headers.Add("Access-Control-Allow-Methods", "POST")  # Allow only POST requests
    $response.Headers.Add("Access-Control-Allow-Headers", "Content-Type")  # Allow Content-Type header
    $response.StatusCode = 200
    $response.StatusDescription = "OK"
}

# Generate initial RSS feed with sample item
function Generate-RSSFeed {
    $initialItem = Create-RSSItem -Title "Sample Title" -Description "Sample Description" -Link "http://example.com" -PubDate (Get-Date)

    $rssContent = @"
    <rss version="2.0">
        <channel>
            <title><![CDATA[Sample RSS Feed]]></title>
            <link>http://localhost:8080/rss</link>
            <description><![CDATA[This is a sample RSS feed generated by PowerShell.]]></description>
            <language>en-us</language>
            <pubDate>$(Get-Date)</pubDate>
            $initialItem
        </channel>
    </rss>
"@
    return $rssContent
}

# Initialize RSS feed content
$rssContent = Generate-RSSFeed

# Define HTTP endpoint
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8080/rss/")
$listener.Prefixes.Add("http://localhost:8080/rssitem/")
$listener.Start()

Write-Host "Listening for incoming HTTP requests on http://localhost:8080/rss/ and http://localhost:8080/rssitem/"

# Serve RSS feed and handle incoming HTTP requests
while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    if ($request.HttpMethod -eq "OPTIONS") {
        # Handle OPTIONS request
        Handle-OptionsRequest $request $response
        $response.Close()
    }
    elseif ($request.Url.AbsolutePath -eq "/rss/") {
        # Handle GET request for the RSS feed
        if ($request.HttpMethod -eq "GET") {
            $response.ContentType = "application/rss+xml"
            $response.Headers.Add("Access-Control-Allow-Origin", "*")  # Allow cross-origin requests
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($rssContent)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        }
    }
    elseif ($request.Url.AbsolutePath -eq "/rssitem/") {
        if ($request.HttpMethod -eq "GET") {
            # Handle GET request for the RSS item
            $response.ContentType = "application/json"
            $response.Headers.Add("Access-Control-Allow-Origin", "*")  # Allow cross-origin requests
            $rssItem = @{
                Title = [xml]$rssContent | Select-Xml -XPath "//item/title" | Select-Object -ExpandProperty Node | Select-Object -ExpandProperty InnerText
                Description = [xml]$rssContent | Select-Xml -XPath "//item/description" | Select-Object -ExpandProperty Node | Select-Object -ExpandProperty InnerText
                Link = [xml]$rssContent | Select-Xml -XPath "//item/link" | Select-Object -ExpandProperty Node | Select-Object -ExpandProperty InnerText
                PubDate = [xml]$rssContent | Select-Xml -XPath "//item/pubDate" | Select-Object -ExpandProperty Node | Select-Object -ExpandProperty InnerText
            }
            $jsonContent = $rssItem | ConvertTo-Json
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($jsonContent)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        }
        elseif ($request.HttpMethod -eq "POST") {
            # Handle POST request to add new RSS item
            $reader = New-Object System.IO.StreamReader($request.InputStream, $request.ContentEncoding)
            $body = $reader.ReadToEnd()
            $reader.Close()

            # Parse JSON body
            $rssItem = ConvertFrom-Json $body

            # Create RSS item from JSON data
            $newItem = Create-RSSItem -Title $rssItem.Title -Description $rssItem.Description -Link $rssItem.Link -PubDate (Get-Date)
            
            # Convert the current RSS content to XML object
            $rssXml = [xml]$rssContent
            
            # Remove the sample item
            $itemNode = $rssXml.SelectSingleNode("//item")
            if ($itemNode -ne $null) {
                $rssXml.rss.channel.RemoveChild($itemNode)
            }

            # Append the new item to the XML
            $newNode = $rssXml.CreateDocumentFragment()
            $newNode.InnerXml = $newItem
            $rssXml.rss.channel.AppendChild($newNode)

            # Convert the updated XML back to string
            $rssContent = $rssXml.OuterXml
            
            # Respond with success message
            $response.ContentType = "text/plain"
            $response.StatusCode = 200
            $response.StatusDescription = "OK"
            $response.Headers.Add("Access-Control-Allow-Origin", "*")  # Allow cross-origin requests
            $buffer = [System.Text.Encoding]::UTF8.GetBytes("RSS item added successfully.")
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        }
    }

    $response.Close()
}

# Stop listening on script exit
$listener.Stop()
