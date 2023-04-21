# ============================================================
# File to scrape the list of all actors and for their genders
# Data Source: https://archive.ics.uci.edu/ml/datasets/Movie
# ============================================================

import pandas as pd


if __name__ == "__main__":
    # Load data and get df
    actors_html = pd.read_html("../data/actors.html")
    actors_df = actors_html[0]
    # Clean actors data frame
    actors_filtered = actors_df.drop(["dow", "dob", "dod", "orig", "pict", "notes", "|", "Unnamed: 12", "Unnamed: 13"], axis = 1)
    actors_filtered.columns = ["stage_name", "real_last_name", "real_first_name", "gender", "role_type"]
    actors_filtered["real_name"] = actors_filtered["real_first_name"] + " " + actors_filtered["real_last_name"]
    actors_filtered = actors_filtered.drop(["real_first_name", "real_last_name"], axis = 1)
    actors_filtered.to_csv("../data/modified/actor_genders_uci.csv")


