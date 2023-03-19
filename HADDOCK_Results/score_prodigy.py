import os, glob
import pandas as pd

'''
Script to score HADDOCK RBD-Antibody Complexes with PRODIGY

## Must have PRODIGY in this directory first (and added to PATH)
git clone https://github.com/haddocking/prodigy && cd prodigy
pip install .
'''

haddock_results = pd.read_excel('../HADDOCK_Results.xlsx')

## Best Structure Measurements (Measure top complex from top cluster)

prodigy_results = pd.DataFrame(columns = ['Job name', 'DGprediction (low refinement) (Kcal/mol)'])

for index, row in haddock_results.iterrows():
    cluster_num = row['Cluster'].replace('C', 'c').replace(' ', '')
    tar_folder = row['Job Tar File'].replace('.tgz', '')
    pdb_path = f'C:\\Users\\Colby\\Documents\\GitHub\\SARS-CoV-2_XBB.1.5_Spike-RBD_Predictions\\HADDOCK_Results\\uncompressed\\{tar_folder}\{cluster_num}_1.pdb'
    print(pdb_path)
    prodigy_output = os.popen(f'prodigy -q {pdb_path}').read()
    print(prodigy_output)
    prodigy_output_df = pd.DataFrame(list(zip([tar_folder], [float(prodigy_output.split('\t')[1].replace('\n',''))])),
                                     columns = ['Job name', 'DGprediction (low refinement) (Kcal/mol)'])
    prodigy_results = prodigy_results.append(prodigy_output_df, ignore_index=True)

prodigy_results.to_csv('PRODIGY_Results.csv')


## Best Cluster Measurements (Measure all complexes from top cluster)

prodigy_results = pd.DataFrame(columns = ['Job name', 'file', 'DGprediction (low refinement) (Kcal/mol)'])

for index, row in haddock_results.iterrows():
    cluster_num = row['Cluster'].replace('C', 'c').replace(' ', '')
    tar_folder = row['Job Tar File'].replace('.tgz', '')
    base_path = f'C:\\Users\\Colby\\Documents\\GitHub\\SARS-CoV-2_XBB.1.5_Spike-RBD_Predictions\\HADDOCK_Results\\uncompressed\\{tar_folder}\\'
    file_list = glob.glob(f'{base_path}{cluster_num}_*.pdb')
    for pdb_path in file_list:
        print(pdb_path)
        pdb_file = os.path.basename(pdb_path)
        prodigy_output = os.popen(f'prodigy -q {pdb_path}').read()
        print(prodigy_output)
        prodigy_output_df = pd.DataFrame(list(zip([tar_folder], [pdb_file], [float(prodigy_output.split('\t')[1].replace('\n',''))])),
                                         columns = ['Job name', 'file', 'DGprediction (low refinement) (Kcal/mol)'])
        prodigy_results = prodigy_results.append(prodigy_output_df, ignore_index=True)

prodigy_results.to_csv('PRODIGY_Results_All.csv')