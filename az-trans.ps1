Param (
    $key,
    $from,
    $to,
    $word
)

if ( !$word ) {
    "[EMPTY]"
    return
}

$uri = 'https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&from={0}&to={1}' -f $from, $to;

$res = Invoke-RestMethod -Method Post -Uri $uri -Headers @{
    'Ocp-Apim-Subscription-Key' = $key;
    'Content-Type' = 'application/json';
} -Body "[{'text': '$word'}]"

if ( $res.Count -ne 0 ) {
    "{0}`n{1}" -f $word, $res[0].translations[0].text
} else {
    "[No Result]"
}
