-- 创建一个画布来显示时间
local timeCanvas = nil
local timeTimer = nil
local menuBarWatcher = nil
local MIN_WINDOW_AREA = 500000

-- 不同应用的时钟位置配置
local CLOCK_CONFIGS = {
	["Zen"] = {
		offsetFromRight = 110,
		offsetFromTop = 11,
		width = 60,
		height = 22,
	},
	["IntelliJ IDEA"] = {
		offsetFromRight = 100,
		offsetFromTop = 11,
		width = 60,
		height = 22,
	},
	["Google Chrome"] = {
		offsetFromRight = 110,
		offsetFromTop = 11,
		width = 60,
		height = 22,
		textColor = { white = 0.0, alpha = 0.85 },
	},
}

-- 检查 menu bar 是否隐藏（更可靠的方法）
local function isMenuBarHidden()
	-- 检查系统偏好设置中 menu bar 是否设置为自动隐藏
	local autohide = hs.execute("defaults read NSGlobalDomain _HIHideMenuBar 2>/dev/null")
	if autohide and autohide:match("1") then
		return true
	end

	-- 检查屏幕可用区域
	local screen = hs.screen.mainScreen()
	local fullFrame = screen:fullFrame()
	local frame = screen:frame()

	-- 如果可用区域的 y 坐标等于完整区域的 y 坐标，说明 menu bar 被隐藏
	-- 并且可用区域的高度等于完整区域的高度
	if frame.y == fullFrame.y and frame.h == fullFrame.h then
		return true
	end

	return false
end

-- 获取应用窗口
local function getAppWindow(appName)
	local app = hs.application.get(appName)
	if app then
		-- 获取应用的主窗口，即使它不在最前面
		local windows = app:allWindows()
		if windows and #windows > 0 then
			local mainWindow = nil
			local maxArea = 0
			for _, win in ipairs(windows) do
				if win:isVisible() then
					local frame = win:frame()
					local area = frame.w * frame.h
					if area > maxArea and area > MIN_WINDOW_AREA then
						maxArea = area
						mainWindow = win
					end
				end
			end
			return mainWindow
		end
	end
	return nil
end

-- 检查某个应用的窗口是否可见
local function isAppWindowVisible(appName)
	local window = getAppWindow(appName)
	return window ~= nil and window:isVisible()
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

	local window = getAppWindow(appName)
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
		textColor = config.textColor or { white = 1.0, alpha = 0.85 },
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
	local window = getAppWindow(appName)
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
	local targetApp = nil
	local orderedWindows = hs.window.orderedWindows()

	for _, win in ipairs(orderedWindows) do
		local app = win:application()
		if app then
			local appName = app:name()
			-- 检查是否是配置的应用，且窗口可见，且 menu bar 隐藏
			if CLOCK_CONFIGS[appName] and isAppWindowVisible(appName) and not menuBarVisible then
				targetApp = appName
				break -- 找到第一个（最前面的）就停止
			end
		end
	end

	if targetApp then
		-- 如果切换了应用，重新创建时钟
		if currentClockApp ~= targetApp then
			currentClockApp = targetApp
			if timeCanvas then
				timeCanvas:delete()
				timeCanvas = nil
			end
			createTimeDisplay(targetApp)
		elseif not timeCanvas then
			createTimeDisplay(targetApp)
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
	-- 使用定时器来处理所有变化（简单且可靠）
	menuBarWatcher = hs.timer.doEvery(0.2, checkAndUpdateDisplay)

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
	hs.reload()
end)

hs.alert.show("Hammerspoon Config Loaded")
