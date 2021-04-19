pragma solidity ^0.4.18;

import 'contracts/addedContracts/Ownable.sol';
import 'contracts/addedContracts/SafeMath.sol';
import 'contracts/addedContracts/DateTime.sol';
import 'contracts/addedContracts/DssVoting.sol';
import 'contracts/addedContracts/DssVotingAction.sol';
import 'contracts/addedContracts/DssVotingEvent.sol';
import 'contracts/addedContracts/DssErrors.sol';

/**
*   @title DssLimits
*   @dev Управление лимитами транзакций между аккаунтами
*/
contract DssLimits is Ownable, DssVotingAction {
    using SafeMath for uint256;

    struct Spent {
        uint256 total;
        uint256 lastPeriod;
    }

    DateTime datetime;

    // СК ошибок
    DssErrors  internal errors;

    // адрес СК банков
    address private banks;

    // адрес СК событий голосований
    address votingEvent;

    struct LimitItem {
        // текущее значение лимита
        uint256 value;
        // адрес СК голосование
        address voting;

    }
    // Хранение информации для завершения голосования
    struct VotingLimits {
        // Тип лимита для аккаунта «операционный»,«ежедневный»,«ежемесячный»,«баланс»,
        uint8 limitType;
        uint8 identityType;
        // новое (предлагаемое) значение лимита
        uint256 candidate;
    }

    LimitItem[3] operationLimits;
    LimitItem[3] dailyLimits;
    LimitItem[3] monthlyLimits;
    LimitItem[3] balanceLimits;

    mapping(address => Spent) daily;
    mapping(address => Spent) monthly;

    mapping(address => VotingLimits) votingResultData;


    /**
     * @dev Конструктор
     * @param _votingEvent address смартконтракт для работы с событиями голосования.
     * @param _banks address смартконтракт для работы с банками.
     * @param _datetime address смартконтракт для работы с датой и временем.
     */
    function DssLimits(address _votingEvent, address _banks, address _errors, address _datetime) public {
        require(_errors != 0x0);
        require(_datetime != 0x0);
        require(_votingEvent != 0x0);

        votingEvent = _votingEvent;
        banks = _banks;
        errors = DssErrors(_errors);
        datetime = DateTime(_datetime);

        // Set default limits
        operationLimits[0].value = 1500000;
        dailyLimits[0].value = 2000000;
        monthlyLimits[0].value = 4000000;

        operationLimits[2].value = 10000000;
        dailyLimits[2].value = 20000000;
        monthlyLimits[2].value = 100000000;
    }

    /**
     * @dev Установка нового значения операционного лимита по переводу средств
     * @param _identityType uint8 Значение типа идентификации аккаунта.
     * @param _newOperationLimit uint256 Значение дневного лимита.
     * @param _endTime uint256 дата окончания голосования.
     * @param _creator address адрес Банка инициатора голосования.
     * @return True - лимит успешно установлен, false - лимит не установлен.
    */
    function updateOperationLimit(uint8 _identityType, uint256 _newOperationLimit, uint256 _endTime, address _creator) public onlyOwner() returns (bool) {
        return updateLimit(operationLimits[_identityType], _identityType, 0, _newOperationLimit, _endTime, _creator);
    }

    /**
     * @dev Проверка привышения операционного лимита по переводу средств
     * @param _identityType uint8 Значение типа идентификации аккаунта.
     * @param _value uint256 Сумма перевода.
     * @return True - лимит не привышен, перевод возможен, false - перевод не возможен.
    */
    function underOperationLimit(uint8 _identityType, uint256 _value) public view onlyOwner() returns (bool) {

        // если лимит установлен в ноль, не делаем проверку
        if (operationLimits[_identityType].value == 0) {
            return true;
        }
        return (_value <= operationLimits[_identityType].value);
    }

    /**
     * @dev Установка нового значения дневного лимита по переводу средств
     * @param _identityType uint8 Значение типа идентификации аккаунта.
     * @param _newDailyLimit uint256 Значение дневного лимита.
     * @param _endTime uint256 дата окончания голосования.
     * @param _creator address адрес Банка инициатора голосования.
     * @return True - лимит успешно установлен, false - лимит не установлен.
    */
    function updateDailyLimit(uint8 _identityType, uint256 _newDailyLimit, uint256 _endTime, address _creator) public onlyOwner() returns (bool) {
        return updateLimit(dailyLimits[_identityType], _identityType, 1, _newDailyLimit, _endTime, _creator);
    }

    /**
     * @dev Проверка привышения дневного лимита по переводу средств
     * @param _account address Адрес аккаунта.
     * @param _identityType uint8 Значение типа идентификации аккаунта.
     * @param _value uint256 Сумма перевода.
     * @return True - лимит не привышен, перевод возможен, false - перевод не возможен.
    */
    function underDailyLimit(address _account, uint8 _identityType, uint256 _value) public onlyOwner() returns (bool) {

        // если лимит установлен в ноль, не делаем проверку
        if (dailyLimits[_identityType].value == 0) {
            return true;
        }

        // обнуляем историю лимита по аккаунту, если последний период отличается от текущего
        if (todayInDays() > daily[_account].lastPeriod) {
            daily[_account].total = 0;
            daily[_account].lastPeriod = todayInDays();
        }

        // Проверка на превышение лимита
        if (daily[_account].total + _value >= daily[_account].total &&
        daily[_account].total + _value <= dailyLimits[_identityType].value) {
            daily[_account].total += _value;
            return true;
        }
        return false;
    }

    /**
     * @dev Уменьшаем ежедневный лимит для указанного аккаунта
     * @param _account address Адрес аккаунта.
     * @param _identityType uint8 Значение типа идентификации аккаунта.
     * @param _value uint256 Сумма перевода.
    */
    function reduceDailyLimit(address _account, uint8 _identityType, uint256 _value) public onlyOwner() {

        // если лимит установлен в ноль, не делаем проверку
        if (dailyLimits[_identityType].value == 0) {
            return;
        }

        // обнуляем историю лимита по аккаунту, если последний период отличается от текущего
        if (todayInDays() > daily[_account].lastPeriod) {
            daily[_account].total = 0;
            daily[_account].lastPeriod = todayInDays();
        }

        // Уменьшаем
        if (daily[_account].total >= _value) {
            daily[_account].total -= _value;
        }
    }

    /**
     * @dev Установка нового значения месячного лимита по переводу средств
     * @param _identityType uint8 Значение типа идентификации аккаунта.
     * @param _newMonthlyLimit uint256 Значение месячного лимита.
     * @param _endTime uint256 дата окончания голосования.
     * @param _creator address адрес Банка инициатора голосования.
     * @return True - лимит успешно установлен, false - лимит не установлен.
    */
    function updateMonthlyLimit(uint8 _identityType, uint256 _newMonthlyLimit, uint256 _endTime, address _creator) public onlyOwner() returns (bool) {
        return updateLimit(monthlyLimits[_identityType], _identityType, 2, _newMonthlyLimit, _endTime, _creator);
    }

    /**
     * @dev Проверка привышения месячного лимита по переводу средств
     * @param _account address Адрес аккаунта.
     * @param _identityType uint8 Значение типа идентификации аккаунта.
     * @param _value uint256 Сумма перевода.
     * @return True - лимит не привышен, перевод возможен, false - перевод не возможен.
    */
    function underMonthlyLimit(address _account, uint8 _identityType, uint256 _value) public onlyOwner() returns (bool) {

        // если лимит установлен в ноль, не делаем проверку
        if (monthlyLimits[_identityType].value == 0) {
            return true;
        }

        // обнуляем историю лимита по аккаунту, если последний период отличается от текущего
        if (todayInMonths() > monthly[_account].lastPeriod) {
            monthly[_account].total = 0;
            monthly[_account].lastPeriod = todayInMonths();
        }

        // Проверка на превышение лимита
        if (monthly[_account].total + _value >= monthly[_account].total &&
        monthly[_account].total + _value <= monthlyLimits[_identityType].value) {
            monthly[_account].total += _value;
            return true;
        }
        return false;
    }

    /**
     * @dev Уменьшаем ежемесячный лимит для указанного аккаунта
     * @param _account address Адрес аккаунта.
     * @param _identityType uint8 Значение типа идентификации аккаунта.
     * @param _value uint256 Сумма перевода.
    */
    function reduceMonthlyLimit(address _account, uint8 _identityType, uint256 _value) public onlyOwner() {

        // если лимит установлен в ноль, не делаем проверку
        if (monthlyLimits[_identityType].value == 0) {
            return;
        }

        // обнуляем историю лимита по аккаунту, если последний период отличается от текущего
        if (todayInMonths() > monthly[_account].lastPeriod) {
            monthly[_account].total = 0;
            monthly[_account].lastPeriod = todayInMonths();
        }

        // Уменьшаем
        if (monthly[_account].total >= _value) {
            monthly[_account].total -= _value;
        }
    }

    /**
     * @dev Установка нового значения лимита по балансу аккаунта
     * @param _identityType uint8 Значение типа идентификации аккаунта.
     * @param _newBalanceLimit uint256 Значение лимита по балансу.
     * @param _endTime uint256 дата окончания голосования.
     * @param _creator address адрес Банка инициатора голосования.
     * @return True - лимит успешно установлен, false - лимит не установлен.
    */
    function updateBalanceLimit(uint8 _identityType, uint256 _newBalanceLimit, uint256 _endTime, address _creator) public onlyOwner() returns (bool) {
        return updateLimit(balanceLimits[_identityType], _identityType, 3, _newBalanceLimit, _endTime, _creator);
    }

    /**
     * @dev Проверка привышения лимита по балансу аккаунта
     * @param _identityType uint8 Значение типа идентификации аккаунта.
     * @param _balance uint256 Текущий баланс аккаунта.
     * @param _value uint256 Сумма перевода.
     * @return True - лимит не привышен, перевод возможен, false - перевод не возможен.
    */
    function underBalanceLimit(uint8 _identityType, uint256 _balance, uint256 _value) public view onlyOwner() returns (bool) {

        // если лимит установлен в ноль, не делаем проверку
        if (balanceLimits[_identityType].value == 0) {
            return true;
        }

        // Проверка на превышение лимита
        if (_balance + _value >= _balance && _balance + _value <= balanceLimits[_identityType].value) {
            return true;
        }
        return false;
    }

    /**
     * @dev Вычисляет от сегодня индекс в днях
     * @return uint256 индекс в днях.
     */
    function todayInDays() public constant returns (uint256) {
        return now / 1 days;
    }

    /**
     * @dev Вычисляет от сегодня индекс в месяцах
     * @return uint16 индекс в месяцах.
     */
    function todayInMonths() public constant returns (uint16) {
        return datetime.getYear(now) * 12 + datetime.getMonth(now);
    }

    /**
     * @dev Возвращает остатки лимитов для переданного аккаунта
     * @param _identityType uint8 Тип идентификации аккаунта.
     * @param _account address Адрес аккаунта.
     */
    function getAccountLimits(uint8 _identityType, address _account) public constant returns (uint256, uint256, uint256, uint256) {
        return (
        operationLimits[_identityType].value,
        calculateDailyAccountLimit(_identityType, _account),
        calculateMonthlyAccountLimit(_identityType, _account),
        balanceLimits[_identityType].value
        );
    }

    /**
     * @dev Вычисляет остаток дневного лимита для переданного аккаунта
     * @param _identityType uint8 Тип идентификации аккаунта.
     * @param _account address Адрес аккаунта.
     */
    function calculateDailyAccountLimit(uint8 _identityType, address _account) public constant returns (uint256) {
        uint256 value = dailyLimits[_identityType].value;
        // если дневной лимит установлен в ноль, не надо вычислять остаток
        if (dailyLimits[_identityType].value != 0) {
            // если текущий период, то вычислим остаток
            if (todayInDays() == daily[_account].lastPeriod) {
                if (value > daily[_account].total) {
                    // вычислим остаток дневного лимита
                    value = value.sub(daily[_account].total);
                } else {
                    value = 0;
                }
            }
        }
        return value;
    }

    /**
     * @dev Вычисляет остаток месячного лимита для переданного аккаунта
     * @param _identityType uint8 Тип идентификации аккаунта.
     * @param _account address Адрес аккаунта.
     */
    function calculateMonthlyAccountLimit(uint8 _identityType, address _account) public constant returns (uint256) {
        uint256 value = monthlyLimits[_identityType].value;
        // если месячный лимит установлен в ноль, не надо вычислять остаток
        if (monthlyLimits[_identityType].value != 0) {
            // если текущий период, то вычислим остаток
            if (todayInMonths() == monthly[_account].lastPeriod) {
                if (value > monthly[_account].total) {
                    // вычислим остаток месячного лимита
                    value = value.sub(monthly[_account].total);
                } else {
                    value = 0;
                }
            }
        }
        return value;
    }

    /**
     * @dev Результат голосования
     */
    function voteResult() public returns (bool){
        if (DssVoting(msg.sender).isFinalized()) {
            VotingLimits memory votingResult = votingResultData[msg.sender];
            // обновляем операционный лимит
            if (votingResult.limitType == 0) {
                operationLimits[votingResult.identityType].value = votingResult.candidate;
                operationLimits[votingResult.identityType].voting = address(0);
            }
            // обновляем ежедневный лимит
            else if (votingResult.limitType == 1) {
                dailyLimits[votingResult.identityType].value = votingResult.candidate;
                dailyLimits[votingResult.identityType].voting = address(0);
            }
            // обновляем ежемесячный лимит
            else if (votingResult.limitType == 2) {
                monthlyLimits[votingResult.identityType].value = votingResult.candidate;
                monthlyLimits[votingResult.identityType].voting = address(0);
            }
            // обновляем лимит баланса аккаунта
            else if (votingResult.limitType == 3) {
                balanceLimits[votingResult.identityType].value = votingResult.candidate;
                balanceLimits[votingResult.identityType].voting = address(0);
            }
        }
    }

    /**
     * @dev Инициализация голосования по смене лимита
     */
    function updateLimit(LimitItem _limitItem, uint8 _identityType, uint8 _limitType, uint256 _newValue, uint256 _endTime, address _creator) internal returns (bool) {

        uint8 votingType = 200 + _limitType * 10 + _identityType;
        // Голосование идет
        if (_limitItem.voting != address(0) && !DssVoting(_limitItem.voting).isFinalized()) {
            DssVotingEvent(votingEvent).EmitVoting(_limitItem.voting, _creator, votingType, _endTime, bytes32(_limitItem.value), bytes32(_newValue), 2, 0, errors.ERROR_VOTING_ALREADY_EXIST());
            return false;
        }

        if (_limitItem.value != _newValue) {
            if (_limitItem.voting == address(0) ||
            DssVoting(_limitItem.voting).isFinalized()) {
                _limitItem.voting = new DssVoting(votingEvent, errors, banks, _endTime, _creator, votingType, bytes32(_limitItem.value), bytes32(_newValue));
            } else if (DssVoting(_limitItem.voting).hasEnded()) {
                DssVoting(_limitItem.voting).finalize();
                _limitItem.voting = new DssVoting(votingEvent, errors, banks, _endTime, _creator, votingType, bytes32(_limitItem.value), bytes32(_newValue));
            }

            votingResultData[_limitItem.voting].limitType = _limitType;
            votingResultData[_limitItem.voting].identityType = _identityType;
            votingResultData[_limitItem.voting].candidate = _newValue;
        } else {
            DssVotingEvent(votingEvent).EmitVoting(address(0), _creator, votingType, _endTime, bytes32(_limitItem.value), bytes32(_newValue), 2, 0, errors.ERROR_VOTING_CONFLICT_VALUE());
        }
        return true;
    }
}
