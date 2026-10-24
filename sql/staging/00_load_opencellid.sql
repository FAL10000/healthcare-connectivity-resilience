CREATE TABLE opencellid_raw AS
SELECT *
FROM read_csv(
        '/home/fal10/PycharmProjects/Healthcare Connectivity Resilience/data/raw/opencellid/510.csv.gz',
        header = false,
    names = [
        'radio',
        'mcc',
        'net',
        'area',
        'cell',
        'unit',
        'lon',
        'lat',
        'range',
        'samples',
        'changeable',
        'created',
        'updated',
        'averageSignal'
            ]
     );