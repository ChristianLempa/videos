import os
import requests
from googleapiclient.discovery import build
import boto3
import botocore

# read youtube api key and channel id from environment variables
youtube_api_key = os.environ.get("YOUTUBE_API_KEY")
youtube_channel_id = os.environ.get("YOUTUBE_CHANNEL_ID")

# read spaces access key and secret from environment variables
spaces_access_key = os.environ.get("SPACES_ACCESS_KEY")
spaces_secret_key = os.environ.get("SPACES_SECRET_KEY")

# read discord webhook url
discord_webhook_url = os.environ.get("DISCORD_WEBHOOK_URL")


# get latest video from a channel
def get_latest_video(channel_id):
    # get latest video from a channel
    youtube = build("youtube", "v3", developerKey=youtube_api_key)

    request = youtube.search().list(
        part="snippet",
        channelId=channel_id,
        order="date",
        maxResults=1
    )

    # execute the request
    response = request.execute()

    # get the video id from the response
    video_id = response["items"][0]["id"]["videoId"]

    # get the video meta data
    request = youtube.videos().list(
        part="snippet,contentDetails,statistics",
        id=video_id
    )

    # execute the request
    response = request.execute()

    # return the video meta data
    return response["items"][0]


# get latest video from s3, if it exists, if not return None
def get_latest_video_from_s3():
    # get latest video from s3, if it exists

    client = boto3.client(
        "s3",
        region_name="fra1",
        endpoint_url="https://fra1.digitaloceanspaces.com",
        aws_access_key_id=spaces_access_key,
        aws_secret_access_key=spaces_secret_key
    )

    try:
        response = client.get_object(
            Bucket="youtubify-demo-2-space",
            Key="latest_video_id.txt"
        )

        # return the video id
        return response["Body"].read().decode("utf-8")
    except botocore.exceptions.ClientError as e:
        if e.response["Error"]["Code"] == "NoSuchKey":
            # the object does not exist
            return None


# push the latest video id to s3
def push_latest_video_to_s3(video_id):
    # push the latest video id to s3

    client = boto3.client(
        "s3",
        region_name="fra1",
        endpoint_url="https://fra1.digitaloceanspaces.com",
        aws_access_key_id=spaces_access_key,
        aws_secret_access_key=spaces_secret_key
    )

    client.put_object(
        Bucket="youtubify-demo-2-space",
        Key="latest_video_id.txt",
        Body=video_id
    )


def main(args):
    # get latest youtube video from a channel
    video = get_latest_video(youtube_channel_id)

    # get latest video id from s3
    latest_video_id = get_latest_video_from_s3()

    # if the latest video id is not the same as the latest video id from s3
    if latest_video_id != video["id"]:
        # create a message with video url that will be pushed to discord
        message = "New video: https://www.youtube.com/watch?v=" + video["id"]

        # push the video url to discord webhook
        requests.post(discord_webhook_url, json={
            "content": message
        })

        # push the latest video id to s3
        push_latest_video_to_s3(video["id"])

        return {"body": "New video"}
    else:
        return {"body": "No new video"}
