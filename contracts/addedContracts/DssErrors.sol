pragma solidity ^0.4.18;

contract DssErrors {

    // Минимальная сумма перевода средств
    uint16 public constant AMOUNT_TX_MIN = 1;

    // Аккаунт существует
    uint16 public constant ERROR_ACCOUNT_EXIST = 100;
    // Идентификатор аккаунта существует
    uint16 public constant ERROR_IDENTIFIER_EXIST = 101;
    // Банк существует
    uint16 public constant ERROR_BANK_EXIST = 102;
    // Валюта существует
    uint16 public constant ERROR_CURRENCY_EXIST = 104;
    // Бизнес контракт существует
    uint16 public constant ERROR_CURRENCY_BUSINESS_CONTRACT_EXIST = 105;
    // Бизнес контракт списания средств существует
    uint16 public constant ERROR_CURRENCY_BUSINESS_WITHDRAW_CONTRACT_EXIST = 106;
    // Бизнес контракт  клиринга существует
    uint16 public constant ERROR_CURRENCY_CLEARING_CONTRACT_EXIST = 107;

    // Доступно только внутренему вызову(Н-р создание escrow аккаунта для SafeDeal)
    uint16 public constant ERROR_AVAILABLE_ONLY_INTERNAL_CONTRACT = 108;

    // Доступно только владельцу аккаунта(Н-р выолнение transfer с аккаунта escrow)
    uint16 public constant ERROR_AVAILABLE_ONLY_OWNER_ACCOUNT = 109;

    // Аккаунт не существует
    uint16 public constant ERROR_ACCOUNT_NOT_EXIST = 110;
    // Идентификатор аккаунта не существует
    uint16 public constant ERROR_IDENTIFIER_NOT_EXIST = 111;
    // Банк не существует
    uint16 public constant ERROR_BANK_NOT_EXIST = 112;
    // Валюта не существует
    uint16 public constant ERROR_CURRENCY_NOT_EXIST = 114;
    // Бизнес контракт не существует
    uint16 public constant ERROR_CURRENCY_BUSINESS_CONTRACT_NOT_EXIST = 115;
    // Бизнес контракт списания средств не существует
    uint16 public constant ERROR_CURRENCY_BUSINESS_WITHDRAW_CONTRACT_NOT_EXIST = 116;
    // Бизнес контракт  клиринга не существует
    uint16 public constant ERROR_CURRENCY_CLEARING_CONTRACT_NOT_EXIST = 117;

    // Аккаунт не существует или заблокирован
    uint16 public constant ERROR_ACCOUNT_NOT_EXIST_OR_NOT_AVAILABLE = 120;
    // Банк не существует или заблокирован
    uint16 public constant ERROR_BANK_NOT_EXIST_OR_NOT_AVAILABLE = 122;
    // Аккаунт создан без идентификатора
    uint16 public constant ERROR_ACCOUNT_CREATED_WITHOUT_IDENTIFIER = 130;

    // Ошибка проверки сигнатуры
    uint16 public constant ERROR_SIGN_VERIFY = 200;
    // Не достаточно средств
    uint16 public constant ERROR_FUNDS_NOT_ENOUGH = 240;

    // Ошибка валидации входных параметров
    uint16 public constant ERROR_VALIDATE_REQUIRED = 300;
    // Попытка перевода суммы меньше минимально допустимой
    uint16 public constant ERROR_VALIDATE_AMOUNT_MIN = 370;
    // Превышен лимит эммиссии средств
    uint16 public constant ERROR_VALIDATE_ISSUE_LIMIT = 380;

    // Попытка перевода средств между юр. лицами
    uint16 public constant ERROR_LIMIT_LEGAL_ENTRY = 410;
    // Превышен операционный лимит перевода средств
    uint16 public constant ERROR_LIMIT_OPERATION = 420;
    // Превышен дневной лимит перевода средств
    uint16 public constant ERROR_LIMIT_DAILY = 430;
    // Превышен месячный лимит перевода средств
    uint16 public constant ERROR_LIMIT_MONTHLY = 440;
    // Превышен допустимый баланс средств
    uint16 public constant ERROR_LIMIT_BALANCE = 450;

    // Счет не существует
    uint16 public constant ERROR_INVOICE_NOT_EXIST = 501;
    // Счет, плательщики не совпадают
    uint16 public constant ERROR_INVOICE_TRANSACTION_PAYER = 502;
    // Счет, получатели не совпадают
    uint16 public constant ERROR_INVOICE_TRANSACTION_RECIPIENT = 503;
    // Счет, суммы не совпадают
    uint16 public constant ERROR_INVOICE_TRANSACTION_AMOUNT= 504;
    // Счет, попытка оплатить ранее оплаченный счет
    uint16 public constant ERROR_INVOICE_TRANSACTION_PAID = 505;
    // Счет, попытка оплатить счета с истекшим сроком жизни
    uint16 public constant ERROR_INVOICE_TRANSACTION_EXPIRED = 506;

    // Голосование, попытка изменить старое значение на такое же новое
    uint16 public constant ERROR_VOTING_CONFLICT_VALUE = 601;

    // Голосование, новое значение не ожидаемо (не проходит валидацию)
    uint16 public constant ERROR_VOTING_BAD_VALUE = 602;

    // Голосование, уже идет голосование и оно не завершено
    uint16 public constant ERROR_VOTING_ALREADY_EXIST = 603;

    // Голосование, уже идет голосование и оно не завершено
    uint16 public constant ERROR_VOTING_WINNING_PROPOSAL_UNDEFINED = 604;

}
