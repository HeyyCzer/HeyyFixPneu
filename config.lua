heyyCfg = {
	repairDuration = 15000, -- Tempo que demorará o reparo
	needsPermission = false, -- Se o reparo só ficará disponível para X permissao. (TRUE = PRECISA DE PERMISSÃO, FALSE = LIBERADO)
	needsPneu = true, -- Se precisará do item "pneus" para efetuar o reparo.
	
	permission = "mecanico.permissao", -- Permissão que será utilizada caso "needsPermission" for TRUE.
	itemIndex = "pneus", -- Nome de spawn do item necessário caso "needsPneu" for TRUE.
	itemAmount = 1, -- Quantidade do item necessária para efetuar o reparo.
}