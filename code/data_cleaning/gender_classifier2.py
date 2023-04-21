# Read in libraries
import gender_guesser.detector as gender
import pandas as pd
import numpy as np


if __name__ == "__main__":
    # Initialize gender detector
    detector = gender.Detector()

    # RUN CLASSIFIER ON DATASET
    # Read in data
    castcrew_ungendered = pd.read_csv("../../data/modified/castcrew_ungendered.csv")

    # Create new column for first names
    firstnames = castcrew_ungendered['primaryName'].str.split(" ", n = 1, expand=True)
    castcrew_ungendered['firstname'] = firstnames[0]

    # Create new gender pred column
    castcrew_ungendered['gender_pred'] = castcrew_ungendered['firstname'].apply(
        lambda x: np.nan if pd.isna(x) else detector.get_gender(str(x))
    )

    # Edit gender pred column if job_title is "actor" or "actress"
    castcrew_ungendered['gender_pred'] = np.where(
        castcrew_ungendered['job_title'] == 'actress',
        "female",
        castcrew_ungendered['gender_pred']
    )
    castcrew_ungendered['gender_pred'] = np.where(
        castcrew_ungendered['job_title'] == 'actor',
        "male",
        castcrew_ungendered['gender_pred']
    )

    # Preview results
    print(castcrew_ungendered.head())

    # Write new csv
    castcrew_ungendered.to_csv('../../data/modified/castcrew_gendered.csv', index=False)