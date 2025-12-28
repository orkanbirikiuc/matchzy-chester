using System.Security.Cryptography;
using System.Text;
using System.Text.Json;


namespace MatchZy
{
    public partial class MatchZy
    {
        // Event name mapping from MatchZy format to Chester format
        private static readonly Dictionary<string, string> ChesterEventNameMapping = new()
        {
            { "going_live", "live_started" },
            { "map_result", "map_ended" },
            { "series_end", "series_ended" },
            { "demo_upload_ended", "demo_ready" },
            { "player_disconnect", "player_disconnected" }
        };

        /// <summary>
        /// Maps MatchZy event names to Chester-compatible event names
        /// </summary>
        private static string GetChesterEventName(string matchZyEventName)
        {
            return ChesterEventNameMapping.TryGetValue(matchZyEventName, out var chesterName)
                ? chesterName
                : matchZyEventName;
        }

        /// <summary>
        /// Computes HMAC-SHA256 signature for webhook authentication
        /// </summary>
        private static string ComputeHmacSha256(string data, string secret)
        {
            if (string.IsNullOrEmpty(secret))
            {
                return "";
            }

            using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(secret));
            var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(data));
            return Convert.ToHexString(hash).ToLowerInvariant();
        }

        public async Task SendEventAsync(MatchZyEvent @event)
        {
            try
            {
                if (string.IsNullOrEmpty(matchConfig.RemoteLogURL)) return;

                Log($"[SendEventAsync] Sending Event: {@event.EventName} for matchId: {liveMatchId} mapNumber: {matchConfig.CurrentMapNumber} on {matchConfig.RemoteLogURL}");

                using var httpClient = new HttpClient();

                // Serialize the event to JSON
                string jsonString = JsonSerializer.Serialize(@event, @event.GetType());

                Log($"[SendEventAsync] SENDING DATA: {jsonString}");

                using var jsonContent = new StringContent(jsonString, Encoding.UTF8, "application/json");

                // Add Chester-required headers
                string chesterEventName = GetChesterEventName(@event.EventName);
                httpClient.DefaultRequestHeaders.Add("X-MatchZy-Event", chesterEventName);
                httpClient.DefaultRequestHeaders.Add("X-MatchZy-Match", liveMatchId.ToString());

                // Add HMAC signature if webhook secret is configured
                if (!string.IsNullOrEmpty(matchConfig.WebhookSecret))
                {
                    string signature = ComputeHmacSha256(jsonString, matchConfig.WebhookSecret);
                    httpClient.DefaultRequestHeaders.Add("X-MatchZy-Signature", $"sha256={signature}");
                }

                // Add custom header if configured (for backwards compatibility)
                if (!string.IsNullOrEmpty(matchConfig.RemoteLogHeaderKey) && !string.IsNullOrEmpty(matchConfig.RemoteLogHeaderValue))
                {
                    httpClient.DefaultRequestHeaders.Add(matchConfig.RemoteLogHeaderKey, matchConfig.RemoteLogHeaderValue);
                }

                var httpResponseMessage = await httpClient.PostAsync(matchConfig.RemoteLogURL, jsonContent);

                if (httpResponseMessage.IsSuccessStatusCode)
                {
                    Log($"[SendEventAsync] Sending {@event.EventName} (as {chesterEventName}) for matchId: {liveMatchId} mapNumber: {matchConfig.CurrentMapNumber} successful with status code: {httpResponseMessage.StatusCode}");
                }
                else
                {
                    Log($"[SendEventAsync] Sending {@event.EventName} (as {chesterEventName}) for matchId: {liveMatchId} mapNumber: {matchConfig.CurrentMapNumber} failed with status code: {httpResponseMessage.StatusCode}, ResponseContent: {await httpResponseMessage.Content.ReadAsStringAsync()}");
                }
            }
            catch (Exception e)
            {
                Log($"[SendEventAsync FATAL] An error occurred: {e.Message}");
            }
        }
    }
}
