$ErrorActionPreference = 'Stop'

function Invoke-WithRetry {
    param(
        [Parameter(Mandatory = $true)][scriptblock]$Request,
        [string]$Name = 'API'
    )

    for ($attempt = 1; $attempt -le 30; $attempt++) {
        try {
            return (& $Request)
        }
        catch {
            if ($attempt -eq 30) { throw }
            Write-Host "$Name is starting. Attempt $attempt/30..."
            Start-Sleep -Seconds 2
        }
    }
}

Write-Host '=== Movie Watchlist demo ===' -ForegroundColor Cyan

$userHealth = Invoke-WithRetry -Name 'User Service' -Request {
    Invoke-RestMethod -Method Get -Uri 'http://localhost:8081/health'
}
$movieHealth = Invoke-WithRetry -Name 'Movie Service' -Request {
    Invoke-RestMethod -Method Get -Uri 'http://localhost:8082/health'
}
$watchlistHealth = Invoke-WithRetry -Name 'Watchlist Service' -Request {
    Invoke-RestMethod -Method Get -Uri 'http://localhost:8083/health'
}

Write-Host "User Service: $($userHealth.status)"
Write-Host "Movie Service: $($movieHealth.status)"
Write-Host "Watchlist Service: $($watchlistHealth.status)"

$timestamp = Get-Date -Format 'yyyyMMddHHmmss'
$userPayload = @{
    name  = 'Demo User'
    email = "demo.$timestamp@example.com"
}
$userBody = ConvertTo-Json -InputObject $userPayload
$user = Invoke-RestMethod -Method Post -Uri 'http://localhost:8081/users' -ContentType 'application/json' -Body $userBody
Write-Host "Created user id=$($user.id)"

$moviePayload = @{
    title = "The Grand Budapest Hotel $timestamp"
    year  = 2014
    genre = 'Comedy'
}
$movieBody = ConvertTo-Json -InputObject $moviePayload
$movie = Invoke-RestMethod -Method Post -Uri 'http://localhost:8082/movies' -ContentType 'application/json' -Body $movieBody
Write-Host "Created movie id=$($movie.id)"

$itemPayload = @{
    movieId = $movie.id
    status  = 'planned'
    notes   = 'Added by the demo script'
}
$itemBody = ConvertTo-Json -InputObject $itemPayload
$itemUri = "http://localhost:8083/watchlists/$($user.id)/items"
$item = Invoke-RestMethod -Method Post -Uri $itemUri -ContentType 'application/json' -Body $itemBody
Write-Host "Movie added to watchlist. Item id=$($item.id)"

$watchlistUri = "http://localhost:8083/watchlists/$($user.id)"
$watchlist = Invoke-RestMethod -Method Get -Uri $watchlistUri
Write-Host ''
Write-Host '=== Retrieved watchlist ===' -ForegroundColor Green
$watchlist | ConvertTo-Json -Depth 10
Write-Host ''
Write-Host 'Demo completed. Save this terminal output for your report.' -ForegroundColor Cyan
