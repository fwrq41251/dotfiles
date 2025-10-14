-- 创建一个画布来显示时间
local timeCanvas = nil
local timeTimer = nil
local menuBarWatcher = nil
local windowFilters = {}

-- 不同应用的时钟位置配置
local CLOCK_CONFIGS = {
	["Zen"] = { -- 记得替换为实际的应用名
		offsetFromRight = 110,
		offsetFromTop = 11,
		width = 60,
		height = 22,
	},
	["IntelliJ IDEA"] = {
		offsetFromRight = 90,
		offsetFromTop = 11,
		width = 60,
		height = 22,
	},
	-- ["Google Chrome"] = {
	--     offsetFromRight = 100,
	--     offsetFromTop = 10,
	--     width = 60,
	--     height = 22
	-- }
}

-- 检查 menu bar 是否隐藏
local function isMenuBarHidden()
	local screen = hs.screen.mainScreen()
	local fullFrame = screen:fullFrame()
	local frame = screen:frame()
	return fullFrame.h == frame.h
end

-- 获取当前应用窗口
local function getCurrentAppWindow(appName)
	local app = hs.application.get(appName)
	if app then
		local window = app:focusedWindow()
		return window
	end
	return nil
end

-- 计算时钟位置
local function calculateClockFrame(windowFrame, config)
	return {
		x = windowFrame.x + windowFrame.w - config.offsetFromRight,
		y = windowFrame.y + config.offsetFromTop,
		w = config.width,
		h = config.height,
	}
end

-- 创建时间显示
local function createTimeDisplay(appName)
	if timeCanvas then
		timeCanvas:delete()
	end

	local window = getCurrentAppWindow(appName)
	if not window then
		return
	end

	local config = CLOCK_CONFIGS[appName]
	if not config then
		return
	end

	local windowFrame = window:frame()
	local clockFrame = calculateClockFrame(windowFrame, config)

	-- 创建画布，相对于浏览器窗口位置
	timeCanvas = hs.canvas.new(clockFrame)

	-- 设置画布层级，确保在最上层
	timeCanvas:level(hs.canvas.windowLevels.overlay)
	timeCanvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)

	-- 添加时间文本（24小时制）
	timeCanvas[1] = {
		type = "text",
		text = os.date("%H:%M"),
		textFont = ".AppleSystemUIFont",
		textSize = 13,
		textColor = { white = 1.0, alpha = 0.85 },
		textAlignment = "right",
		frame = { x = 0, y = 0, w = config.width, h = config.height },
	}

	timeCanvas:show()
end

-- 更新时间显示
local function updateTime()
	if timeCanvas and isMenuBarHidden() then
		timeCanvas[1].text = os.date("%H:%M")
	end
end

-- 更新时钟位置（跟随窗口）
local function updatePosition(appName)
	local window = getCurrentAppWindow(appName)
	if not window or not timeCanvas then
		return
	end

	local config = CLOCK_CONFIGS[appName]
	if not config then
		return
	end

	local windowFrame = window:frame()
	local clockFrame = calculateClockFrame(windowFrame, config)
	timeCanvas:frame(clockFrame)
end

-- 当前显示时钟的应用名称
local currentClockApp = nil

-- 检查并更新显示状态
local function checkAndUpdateDisplay()
	local currentApp = hs.application.frontmostApplication()
	local appName = currentApp:name()

	-- 只在配置表中存在的应用并且 menu bar 隐藏时显示
	if CLOCK_CONFIGS[appName] and isMenuBarHidden() then
		-- 如果切换了应用，重新创建时钟
		if currentClockApp ~= appName then
			currentClockApp = appName
			if timeCanvas then
				timeCanvas:delete()
				timeCanvas = nil
			end
			createTimeDisplay(appName)
		elseif not timeCanvas then
			createTimeDisplay(appName)
		end

		if not timeTimer then
			timeTimer = hs.timer.doEvery(1, function()
				updateTime()
				if currentClockApp then
					updatePosition(currentClockApp)
				end
			end)
		end
	else
		currentClockApp = nil
		if timeCanvas then
			timeCanvas:delete()
			timeCanvas = nil
		end
		if timeTimer then
			timeTimer:stop()
			timeTimer = nil
		end
	end
end

-- 监听窗口移动和调整大小
local function setupWatcher()
	-- 监听应用切换和窗口变化
	menuBarWatcher = hs.timer.doEvery(0.5, checkAndUpdateDisplay)

	-- 为每个配置的应用创建窗口过滤器
	for appName, _ in pairs(CLOCK_CONFIGS) do
		local filter = hs.window.filter.new(false)
		filter:setAppFilter(appName)

		filter:subscribe({ hs.window.filter.windowMoved, hs.window.filter.windowResized }, function()
			if currentClockApp == appName then
				updatePosition(appName)
			end
		end)

		table.insert(windowFilters, filter)
	end

	-- 初始检查
	checkAndUpdateDisplay()
end

-- 启动
setupWatcher()

-- 添加快捷键显示当前应用名称
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "A", function()
	local app = hs.application.frontmostApplication()
	local appName = app:name()
	hs.alert.show("Current App: " .. appName, 3)
end)

-- 当配置重新加载时清理
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "R", function()
	if timeCanvas then
		timeCanvas:delete()
	end
	if timeTimer then
		timeTimer:stop()
	end
	if menuBarWatcher then
		menuBarWatcher:stop()
	end
	for _, filter in ipairs(windowFilters) do
		filter:unsubscribeAll()
	end
	hs.reload()
end)

hs.alert.show("Hammerspoon Config Loaded")
