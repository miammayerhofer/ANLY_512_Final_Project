import pandas as pd
import nltk
import random
from nltk.corpus import names



if __name__ == "__main__":
    # Read in the data
    males = pd.read_csv("../../data/nltk_gender/males.txt", header = None)
    females = pd.read_csv("../../data/nltk_gender/females.txt", header = None)
    males = pd.DataFrame(males)
    males.columns = ["names"]
    females = pd.DataFrame(females)
    females.columns = ["names"]
    # Infer gender of all the names
    # Source code: https://www.geeksforgeeks.org/python-gender-identification-by-name-using-nltk/
    def gender_features(word):
        return {"last_letter": word[-1]}
    # Preparing a list of examples and corresponding class labels
    labeled_names = ([(name, "male") for name in list(males["names"])]+
                [(name, "female") for name in list(females["names"])])
    random.shuffle(labeled_names)
    # Use the feature extractor to process the names data
    featuresets = [(gender_features(n), gender) 
                for (n, gender)in labeled_names]
    # Divide the resulting list of feature sets into a training set and a test set
    train_set, test_set = featuresets[500:], featuresets[:500]
    # Train a new "naive Bayes" classifier.
    classifier = nltk.NaiveBayesClassifier.train(train_set)
    print(classifier.classify(gender_features("tereza")))
    print(nltk.classify.accuracy(classifier, train_set))


