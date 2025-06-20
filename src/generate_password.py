import argparse
import random
import string
import sys


def generate_password(
    length: int,
    use_upper: bool,
    use_digits: bool,
    use_symbols: bool,
) -> str:
    """
    Генерирует безопасный пароль на основе заданных параметров.

    :param length: Длина пароля (должна быть положительным числом)
    :param use_upper: Использовать символы в верхнем регистре
    :param use_digits: Использовать цифры
    :param use_symbols: Использовать специальные символы
    :return: Пароль
    """
    if length <= 0:
        sys.exit("Ошибка: длина пароля должна быть положительным числом.")

    char_sets = string.ascii_lowercase
    if use_upper:
        char_sets += string.ascii_uppercase
    if use_digits:
        char_sets += string.digits
    if use_symbols:
        char_sets += "!@#$%^&*()-_=+[]{};:,.<>?"

    # Гарантируем, что хотя бы один символ из каждого выбранного набора попадёт в пароль
    password = []
    if use_upper:
        password.append(random.choice(string.ascii_uppercase))
    if use_digits:
        password.append(random.choice(string.digits))
    if use_symbols:
        password.append(random.choice("!@#$%^&*()-_=+[]{};:,.<>?"))

    # Остальные символы
    while len(password) < length:
        password.append(random.choice(char_sets))

    random.shuffle(password)
    return "".join(password)


def main() -> None:
    """Главная функция для запуска генератора паролей из командной строки."""

    parser = argparse.ArgumentParser(description="Генератор безопасного пароля.")
    parser.add_argument(
        "--length",
        "-l",
        type=int,
        default=12,
        help="Минимальная длина пароля (по умолчанию: 12)",
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
        use_upper=args.upper,
        use_digits=args.digits,
        use_symbols=args.symbols,
    )

    print(f"Сгенерированный пароль: {password}")
