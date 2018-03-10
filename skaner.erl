-module(skaner).
-author('AleksanderLisiecki').
-export([scan/1]).

% cd("C:/Users/alekl/Documents/projekty/SQLSkanerErlang").

scan(Input) -> try_tokenze(Input).

try_tokenze("") -> tokenized_finished; 
try_tokenze(Input) ->
    NextToken = find_next_token(Input,"",[]),
    case NextToken of
        {no_match,NotMachedString} -> io:fwrite("~p does not match any allowed pattern \n",[NotMachedString]);
        {full_match, TokenName, String} -> 
            io:fwrite("~p managed to be tokenized as ~p\n",[String,TokenName]),
            NewInput = Input -- String,
            try_tokenze(NewInput)
    end.

find_next_token([],CosideredString,[]) -> {no_match,CosideredString};
find_next_token([],_CosideredString,ListOfFullMaches) -> get_longest_token(ListOfFullMaches);
find_next_token(Input,PreviouslyConsideredSubstring,FullMaches) ->
    CurrentlyConsideredSubstring = PreviouslyConsideredSubstring ++ [hd(Input)],
    NewFullMachs = get_full_matchs(CurrentlyConsideredSubstring),
    PartialMaches = get_partial_matchs(CurrentlyConsideredSubstring),
    if
        length(NewFullMachs) + length(PartialMaches) == 0 -> 
            if  
                length(FullMaches) == 0 -> {no_match,CurrentlyConsideredSubstring};
                true -> get_longest_token(FullMaches)
            end;
        length(NewFullMachs) + length(PartialMaches) > 0 -> find_next_token(tl(Input),CurrentlyConsideredSubstring,FullMaches ++ NewFullMachs)
    end.

get_longest_token([{TokenName,String}]) -> {full_match, TokenName, String};
get_longest_token(List) -> get_longest_token(List,hd(List)).

get_longest_token([],{TokenName,String}) -> {full_match, TokenName, String};
get_longest_token([{HTokenName,HString}|T],{MaxTokenName,MaxString}) ->
    if
        length(HString) > length(MaxString) -> get_longest_token(T,{HTokenName,HString});
        ((length(HString) == length(MaxString)) and (HTokenName /= MaxTokenName)) -> erlang:error("to different tokens match the same input");
        length(HString) == length(MaxString) -> get_longest_token(T,{MaxTokenName,MaxString});
        length(HString) < length(MaxString) -> get_longest_token(T,{MaxTokenName,MaxString})
    end.

get_full_matchs(Input) -> [] ++
        full_match_matematical_operator(Input) ++
        full_match_agregator(Input) ++
        full_match_logical_operator(Input).

get_partial_matchs(Input) -> [] ++
        partial_match_agregator(Input) ++
        partial_match_matematical_operator(Input) ++
        partial_match_logical_operator(Input).

partial_match_matematical_operator(_InputPotencialToken) -> [].

full_match_matematical_operator(InputPotencialToken) ->
    case lists:any(fun(X) -> InputPotencialToken =:= X end, ["+","-","/"]) of
        true -> [{matematical_operator,InputPotencialToken}];
        _ -> []
    end.

partial_match_agregator(InputPotencialToken) ->
    InputToUpper = string:to_upper(InputPotencialToken),
    case lists:any(fun(X) -> X ==  InputToUpper end, ["S","SU","A","AV"]) of
        true -> [{agregator,InputPotencialToken}];
        _ -> []
    end.

full_match_agregator(InputPotencialToken) ->
    InputToUpper = string:to_upper(InputPotencialToken),
    case lists:any(fun(X) -> X == InputToUpper end, ["SUM","AVG"]) of
        true -> [{agregator,InputPotencialToken}];
        _ -> []
    end.

partial_match_logical_operator(InputPotencialToken) ->
    InputToUpper = string:to_upper(InputPotencialToken),
    case lists:any(fun(X) -> X == InputToUpper end, ["A","AN","O","N","NO"]) of
        true -> [{agregator,InputPotencialToken}];
        _ -> []
    end.

full_match_logical_operator(InputPotencialToken) ->
    InputToUpper = string:to_upper(InputPotencialToken),
    case lists:any(fun(X) -> X == InputToUpper end, ["AND","OR","NOT"]) of
        true -> [{agregator,InputPotencialToken}];
        _ -> []
    end.