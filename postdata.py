import pandas as pd

# convert a CSV file in the "right" format by converting the "Score" column into 4 columns (Min, Max, Mean, Std)
# quite ad-hoc but needed (another option would be to use an already existing CSV file with the right format)

fname = "results.csv"
df = pd.read_csv(fname)
df[['Min', 'Max', 'Mean', 'Std']] = df['Score'].str.extract(r"Min: (\d+(?:\.\d+)?)% Max: (\d+(?:\.\d+)?)% Mean: (\d+(?:\.\d+)?)%(?: Std: ([\d\.]+))?")
df = df.drop('Score', axis=1)
# save in CSV
df.to_csv(fname) # same filename

