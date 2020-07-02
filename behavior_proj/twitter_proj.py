#!/usr/bin/env python
import twitter_cred
import sys
import tweepy
from wordcloud import WordCloud
from PIL import Image

# Sets authentication for twitter api
auth = tweepy.OAuthHandler(twitter_cred.API_KEY, twitter_cred.API_SECRET)
auth.set_access_token(twitter_cred.ACCESS_TOKEN, twitter_cred.ACCESS_SECRET)

api = tweepy.API(auth)

keyword = sys.argv[1]

wc = WordCloud(max_font_size=100, width=600, height=300, relative_scaling=.5)

# Takes in a list and puts all elements in a string
def listToString(s):

    str1 = ""

    for ele in s:
        str1 += ele + ' '

    return str1


# Retrieves text from tweets based off a keyword, converts to string
def getStringOfText(query):

    tweetslst = []

    for tweet in api.search(q = query, lang = 'en', result_type = 'mixed', tweet_mode = 'extended', count = 20):
        encoded_string = tweet.full_text.encode("ascii", "ignore")
        decode_string = encoded_string.decode()
        tweetlist = decode_string.split(' ')
        tweetslst = tweetslst + tweetlist

    # Removes unwanted words
    res = [x for x in tweetslst if not x.startswith('https')]
    res1 = [x for x in res if not "http" in x]
    res2 = [x for x in res1 if not "u2019" in x]

    # Correctly formats
    strvar = listToString(res2)
    strvarlow = strvar.lower()

    return strvarlow


wc.generate(getStringOfText(keyword))

wc.to_file('output.png')
img = Image.open('output.png')
img.show()








