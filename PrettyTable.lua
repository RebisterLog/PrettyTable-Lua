local DEFAULT_COLUMN_SIZE = 5 --Count in symbols
local VERTICAL_SYMBOL = "═"
local HORIZONTAL_SYMBOL = "║"
local ANGLE_SYMBOL = "+"

local AllTables = {}

local Table = {}

local function isArray(tab)
	return #tab > 0
end

function Table:AddRow( row )
	if not isArray(row) then return end
	table.insert(self.Rows, row)
end

function Table:AddColumn( name )
	table.insert(self.Columns, name)
end

function Table:AddColumns( columns )
	if not isArray(columns) then return end
	
	for i, name in pairs(columns) do
		table.insert(self.Columns, name)
	end
end 

function Table:AddRows( rows )
	if not isArray(rows) then return end

	for i, row in pairs(rows) do
		table.insert(self.Rows, row)
	end
end 

function Table:Remove()
	AllTables[self.Name] = nil
	self = nil
end

local function GetColumnWeight( prettyTable )
	local weight = DEFAULT_COLUMN_SIZE
	
	for i, row in pairs(prettyTable.Rows) do
		for i, info in pairs(row) do
			if weight < tostring(info):len() then
				weight = tostring(info):len()
			end
		end
	end
	
	for i, column in pairs(prettyTable.Columns) do
		if weight < tostring(column):len() then
			weight = tostring(column):len()
		end
	end
	
	return weight
end

local function GetCell( name, cellWeight )
	local spacebar = " "
	return VERTICAL_SYMBOL.." "..name..spacebar:rep(cellWeight - name:len()).." "
end

local function Graf( columnsCount, cellWeight )
	local graf = HORIZONTAL_SYMBOL
	return graf:rep(columnsCount*(cellWeight+3)+1)
end

local function PrintTable( prettyTable )
	local text="\n"
	
	local cellWeight = GetColumnWeight(prettyTable)
	
	text = text..Graf(#prettyTable.Columns,cellWeight)..'\n'
	
	for i, column in pairs(prettyTable.Columns) do
		local cell = GetCell( tostring(column), cellWeight )
		text = text..cell
	end
	text= text.."|\n"
	
	for i, row in pairs(prettyTable.Rows) do
		text = text..Graf(#prettyTable.Columns,cellWeight)..'\n'
		for i, info in pairs(row) do
			local cell = GetCell( info, cellWeight )
			text = text..cell
			
		end
		text= text.."|\n"
	end
	
	text = text..Graf(#prettyTable.Columns,cellWeight)..'\n'
	return text
end

local PrettyTable = {}

function PrettyTable.new( name )
	local self = setmetatable(
		{
			Name = name,
			Rows = {},
			Columns = {}
		},
		{
			__index = Table,
			__tostring = function()
				local tab = AllTables[name]
				return PrintTable(tab)
			end,
			
		})
	AllTables[name] = self
	return self
end

function PrettyTable:Convert( name, tab )
	if isArray(tab) then return end
	
	local columnsNames = {}
	local row = {}
	
	for i, info in pairs(tab) do
		table.insert(columnsNames,tostring(i))
		if typeof(info)=="table" then
			
			local success = pcall(function()
				table.insert(row,table.unpack(info))
			end)
			if not success then table.insert(row,"{...}") end
		else
			table.insert(row,tostring(info))
		end
	end
	
	local tab = PrettyTable.new(name)
	tab:AddColumns(columnsNames)
	tab:AddRow(row)
	
	return tab

end

return PrettyTable
