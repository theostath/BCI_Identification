import pytest

from bci_identification.cli import build_parser


def test_defaults():
    args = build_parser().parse_args(["run", "--data-dir", "d"])
    assert args.data_dir == "d"
    assert args.metric == "all"
    assert args.band == "all"
    assert args.car is True
    assert args.out == "results"
    assert args.plot is False


def test_explicit_metric_band_and_no_car():
    args = build_parser().parse_args(
        ["run", "--data-dir", "d", "--metric", "PLV", "--band", "alpha", "--no-car"]
    )
    assert args.metric == "PLV"
    assert args.band == "alpha"
    assert args.car is False


def test_plot_flag():
    args = build_parser().parse_args(["run", "--data-dir", "d", "--plot"])
    assert args.plot is True


def test_data_dir_required():
    with pytest.raises(SystemExit):
        build_parser().parse_args(["run"])
