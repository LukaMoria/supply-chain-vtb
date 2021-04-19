pragma solidity ^0.4.18;

/**
 * @title DssVotingEvent
 * @dev Контракт обработки события голосования.
 */
contract DssVotingEvent {

    /**
    * @dev Событие по изменению статуса голосования
    * @param voting address Адрес СК голосования
    * @param bank address Адрес банка-инициатора голосования
    * @param votingType uint8 Предмет голосования
    * @param endTime uint256 Дата и время окончания голосования
    * @param oldValue bytes32 Старое значение
    * @param newValue bytes32 Новое значение
    * @param status uint8 Статус голосования - 0: голосование создано, 1: голосование закончено, 2: ошибка
    * @param result uint8 Результат голосования - 0: результат не определен, 1: голосование ЗА, 2: голосование ПРОТИВ, 3: время голосования истекло
    * @param errorCode uint16 Код ошибки
    * @param dt uint Дата и время события
    *
    */
    event Voting(
        address indexed voting,
        address indexed bank,
        uint8 indexed votingType,
        uint endTime,
        bytes32 oldValue,
        bytes32 newValue,
        uint8 status,
        uint8 result,
        uint16 errorCode,
        uint dt);

    /**
    * @dev Событие по процессу голосования банка
    * @param voting address Адрес СК голосования
    * @param bank address Адрес банка-голосующего
    * @param name bytes32 Название банка
    * @param bik bytes32 ДБИК банка
    * @param result uint8 Результат голосования - 0: результат не определен, 1: голосование ЗА, 2: голосование ПРОТИВ, 3: время голосования истекло
    * @param errorCode uint16 Код ошибки
    * @param canFinalize bool Признак того, что можно завершить - true или нет - false голосование
    * @param dt uint Дата и время голосования
    *
    */
    event VotingProcess(
        address indexed voting,
        address indexed bank,
        bytes32 name,
        bytes32 bik,
        uint8 result,
        uint16 errorCode,
        bool canFinalize,
        uint dt);

    function EmitVoting(address voting, address bank, uint8 votingType, uint endTime,
        bytes32 oldValue, bytes32 newValue, uint8 status, uint8 result, uint16 errorCode) public {
        Voting(voting, bank, votingType, endTime, oldValue, newValue, status, result, errorCode, now);
    }

    function EmitVotingProcess(address voting, address bank, bytes32 name, bytes32 bik, uint8 result, uint16 errorCode, bool canFinalize) public {
        VotingProcess(voting, bank, name, bik, result, errorCode, canFinalize, now);
    }

}