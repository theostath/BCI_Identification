from bci_identification.io import subject_filename


def test_subject_filename_zero_pads():
    assert subject_filename(1, 1) == "S001R01.edf"
    assert subject_filename(5, 2) == "S005R02.edf"
    assert subject_filename(10, 1) == "S010R01.edf"
    assert subject_filename(100, 2) == "S100R02.edf"
    assert subject_filename(109, 1) == "S109R01.edf"
