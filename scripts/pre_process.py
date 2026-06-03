import pandas as pd

hn = pd.read_csv('hn.csv', delimiter=',')
hn_removed_cols = hn.drop(labels=['Object ID', 'Title', 'Author', 'URL', 'Post Type'], axis=1)
hn_dropped_na = hn_removed_cols.dropna()

hn_formated = hn_dropped_na

hn_formated['Points'] = hn_formated['Points'].apply(lambda x: f'{x:04d}')
hn_formated['Number of Comments'] = hn_formated['Number of Comments'].astype(int).apply(lambda x: f'{x:04d}')
hn_formated['Created At'] = pd.to_datetime(hn_formated['Created At']).dt.strftime('%Y%m')

hn_formated.to_csv('hn_formated.csv', index=False, header=False)