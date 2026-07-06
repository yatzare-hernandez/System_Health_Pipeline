import json
import requests
from collections import Counter
from pathlib import Path

project_root = Path(__file__).resolve().parent.parent

json_file = project_root / "data" / "health_report.json"
config_file = project_root / "config" / "discord_config.json"

# Read configuration
with open(config_file, "r") as f:
     config = json.load(f)

webhook_url = config["webhook_url"]

# Read report
with open(json_file, "r") as f:
     data = json.load(f)

severity_count = Counter(item["severity"] for item in data)

hostname = data[-1]["hostname"]

timestamp = data[-1]["timestamp"]

critical_alerts = set()

for item in data:
     if item["severity"] == "CRITICAL":
           critical_alerts.update(item["alerts"])

if severity_count["CRITICAL"] > 0:
      color = 15158332
      status = "CRITICAL"
elif severity_count["WARNING"] > 0:
      color = 16776960
      status = "WARNING"
else:
      color = 3447003
      status = "INFO"

embed = {
  
    "title": "System Health Pipeline",
     
    "color": color,

    "fields": [

        {
              "name": "Server",
              "value": hostname,
              "inline": True
         },

         {
              "name": "Overall Status",
              "value": status,
              "inline":
 True
         },

          {
              "name": "Events",
              "value":
              f"INFO: {severity_count['INFO']}\n"
              f"WARNING: {severity_count['WARNING']}\n"
              f"CRITICAL: {severity_count['CRITICAL']}",
              "inline": False
         },

         {
             "name": "Critical Alerts",
             "value": "\n".join(critical_alerts) if critical_alerts else "None",
             "inline": False
         },

         {
            "name": "Generated",
            "value": timestamp,
            "inline": False
         }

       ]
  }

payload = {

    "username": "System Health Pipeline",

    "embeds": [embed]

}

response = requests.post(webhook_url, json=payload)

if response.status_code == 204:

    print("Discord notification sent successfully.")

else:

     print("Error sending notification.")

     print(response.status_code)

     print(response.text)




