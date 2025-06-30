#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
# ]
# ///
import argparse
import secrets
import string
import sys

__all__ = ("generate_password",)


def generate_password(
    length: int,
    upper: bool,
    digits: bool,
    symbols: bool,
) -> str:
    """
    Генерирует безопасный пароль на основе заданных параметров, используя криптографически безопасный генератор.

    :param length: Длина пароля (должна быть не менее 8 символов)
    :param upper: Использовать символы в верхнем регистре
    :param digits: Использовать цифры
    :param symbols: Использовать специальные символы
    :return: Пароль
    """
    if length < 8:
        sys.exit("Ошибка: для безопасности длина пароля должна быть не менее 8 символов.")

    char_sets = {
        "lower": string.ascii_lowercase,
        "upper": string.ascii_uppercase if upper else "",
        "digits": string.digits if digits else "",
        "symbols": "!@#$%^&*()-_=+[]{};:<>?" if symbols else "",
    }

    # Создаем объединенный набор символов
    all_chars = "".join(char_sets.values())

    # Гарантируем, что хотя бы один символ из каждого выбранного набора будет в пароле
    password = []
    for char_set in char_sets.values():
        if char_set:
            password.append(secrets.choice(char_set))

    # Добавляем оставшиеся символы
    while len(password) < length:
        password.append(secrets.choice(all_chars))

    # Перемешиваем для случайного порядка
    secrets.SystemRandom().shuffle(password)

    return "".join(password)


def main() -> None:
    """Главная функция для запуска генератора паролей из командной строки."""
    parser = argparse.ArgumentParser(description="Генератор безопасного пароля.")
    parser.add_argument(
        "--length",
        "-l",
        type=int,
        default=12,
        help="Длина пароля (минимум 8, по умолчанию: 12)",
    )
    parser.add_argument(
        "--upper",
        "-u",
        action="store_true",
        help="Включить символы в верхнем регистре",
    )
    parser.add_argument(
        "--digits",
        "-d",
        action="store_true",
        help="Включить цифры",
    )
    parser.add_argument(
        "--symbols",
        "-s",
        action="store_true",
        help="Включить специальные символы",
    )
    args = parser.parse_args()

    password = generate_password(
        length=args.length,
        upper=args.upper,
        digits=args.digits,
        symbols=args.symbols,
    )
    print(password)


if __name__ == "__main__":
    main()
