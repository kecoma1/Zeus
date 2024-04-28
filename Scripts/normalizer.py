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
        
        # separating the lines and the header
        header = lines[0]
        
        # Parsing the header
        header_parsed = header.replace('\n', '').split(',')
        
        data = []
        
        for line in lines[1::]:
            data.append([float(value) for value in line.replace('\n', '').split(',')])
            
        return pd.DataFrame(data, columns=header_parsed)
    
def normalizar(columna, df):
    min = df[columna].min()
    max = df[columna].max()
    df[columna] = (df[columna] - min) / (max - min)

df = read_file('zeus-init.csv')

# Normalizamos
normalizar('CD', df)
normalizar('CT', df)
df.to_csv('zeus-init-normalizado.csv', index=False)