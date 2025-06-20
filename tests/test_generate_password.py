"""
module: test_generate_password
description:
============================
author: neyakki <neyakki@gmail.com>
"""

import string

import pytest

from src.generate_password import generate_password


@pytest.mark.parametrize(
    "length, use_upper, use_digits, use_symbols, expected_checks",
    [
        (12, True, False, False, [string.ascii_uppercase]),
        (12, False, True, False, [string.digits]),
        (12, False, False, True, ["!@#$%^&*()-_=+[]{};:,.<>?"]),
        (
            12,
            True,
            True,
            True,
            [string.ascii_uppercase, string.digits, "!@#$%^&*()-_=+[]{};:,.<>?"],
        ),
        (8, False, False, False, [string.ascii_lowercase]),
    ],
)
def test_password_contains_expected_characters(
    length: int,
    use_upper: bool,
    use_digits: bool,
    use_symbols: bool,
    expected_checks: str,
):
    password = generate_password(
        length=length,
        use_upper=use_upper,
        use_digits=use_digits,
        use_symbols=use_symbols,
    )

    # Проверка длины
    assert len(password) == length

    # Проверка, что пароль содержит хотя бы по одному символу из каждого набора
    for charset in expected_checks:
        assert any(c in charset for c in password)
