import pandas as pd

def correct_lines(lines):
    corrected_lines = []
    for line in lines:
        corrected_lines.append(line.replace('\n', ''))
    return corrected_lines

def read_file(filename):
    lines = None
    with open(filename) as f:
        lines = correct_lines(f.readlines())
        
        data = []
        for line in lines[1::]:
            data.append([ float(value) for value in line.split(',') ])
            
        return pd.DataFrame(data, columns=lines[0].split(','))
    
def normalizar(column, df):
    min = df[column].min()
    max = df[column].max()
    print(column, 'mínimo', min)
    print(column, 'máximo', max)
    df[column] = (df[column] - min) / (max - min)
            
filename = 'zeus-init'
df = read_file(f'C:/Users/kevin/AppData/Roaming/MetaQuotes/Terminal/Common/Files/{filename}-sin-normalizar.csv')
normalizar('CT', df)
normalizar('CD', df)
df.to_csv(f'C:/Users/kevin/AppData/Roaming/MetaQuotes/Terminal/Common/Files/{filename}-normalizado.csv', index=False)

