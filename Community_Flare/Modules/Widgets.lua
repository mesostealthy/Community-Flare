-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                                               = _G
local GetBulletTextListWidgetVisualizationInfo                         = _G.C_UIWidgetManager.GetBulletTextListWidgetVisualizationInfo
local GetButtonHeaderWidgetVisualizationInfo                           = _G.C_UIWidgetManager.GetButtonHeaderWidgetVisualizationInfo
local GetCaptureBarWidgetVisualizationInfo                             = _G.C_UIWidgetManager.GetCaptureBarWidgetVisualizationInfo
local GetCaptureZoneVisualizationInfo                                  = _G.C_UIWidgetManager.GetCaptureZoneVisualizationInfo
local GetDiscreteProgressStepsVisualizationInfo                        = _G.C_UIWidgetManager.GetDiscreteProgressStepsVisualizationInfo
local GetDoubleIconAndTextWidgetVisualizationInfo                      = _G.C_UIWidgetManager.GetDoubleIconAndTextWidgetVisualizationInfo
local GetDoubleStateIconRowVisualizationInfo                           = _G.C_UIWidgetManager.GetDoubleStateIconRowVisualizationInfo
local GetDoubleStatusBarWidgetVisualizationInfo                        = _G.C_UIWidgetManager.GetDoubleStatusBarWidgetVisualizationInfo
local GetFillUpFramesWidgetVisualizationInfo                           = _G.C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo
local GetHorizontalCurrenciesWidgetVisualizationInfo                   = _G.C_UIWidgetManager.GetHorizontalCurrenciesWidgetVisualizationInfo
local GetIconAndTextWidgetVisualizationInfo                            = _G.C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo
local GetIconTextAndBackgroundWidgetVisualizationInfo                  = _G.C_UIWidgetManager.GetIconTextAndBackgroundWidgetVisualizationInfo
local GetIconTextAndCurrenciesWidgetVisualizationInfo                  = _G.C_UIWidgetManager.GetIconTextAndCurrenciesWidgetVisualizationInfo
local GetItemDisplayVisualizationInfo                                  = _G.C_UIWidgetManager.GetItemDisplayVisualizationInfo
local GetMapPinAnimationWidgetVisualizationInfo                        = _G.C_UIWidgetManager.GetMapPinAnimationWidgetVisualizationInfo
local GetPreyHuntProgressWidgetVisualizationInfo                       = _G.C_UIWidgetManager.GetPreyHuntProgressWidgetVisualizationInfo
local GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo  = _G.C_UIWidgetManager.GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo
local GetScenarioHeaderDelvesWidgetVisualizationInfo                   = _G.C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo
local GetScenarioHeaderTimerWidgetVisualizationInfo                    = _G.C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo
local GetSpacerVisualizationInfo                                       = _G.C_UIWidgetManager.GetSpacerVisualizationInfo
local GetSpellDisplayVisualizationInfo                                 = _G.C_UIWidgetManager.GetSpellDisplayVisualizationInfo
local GetStackedResourceTrackerWidgetVisualizationInfo                 = _G.C_UIWidgetManager.GetStackedResourceTrackerWidgetVisualizationInfo
local GetStatusBarWidgetVisualizationInfo                              = _G.C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo
local GetTextureAndTextRowVisualizationInfo                            = _G.C_UIWidgetManager.GetTextureAndTextRowVisualizationInfo
local GetTextureAndTextVisualizationInfo                               = _G.C_UIWidgetManager.GetTextureAndTextVisualizationInfo
local GetTextureWithAnimationVisualizationInfo                         = _G.C_UIWidgetManager.GetTextureWithAnimationVisualizationInfo
local GetTextColumnRowVisualizationInfo                                = _G.C_UIWidgetManager.GetTextColumnRowVisualizationInfo
local GetTextWithStateWidgetVisualizationInfo                          = _G.C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo
local GetTextWithSubtextWidgetVisualizationInfo                        = _G.C_UIWidgetManager.GetTextWithSubtextWidgetVisualizationInfo
local GetTugOfWarWidgetVisualizationInfo                               = _G.C_UIWidgetManager.GetTugOfWarWidgetVisualizationInfo
local GetUnitPowerBarWidgetVisualizationInfo                           = _G.C_UIWidgetManager.GetUnitPowerBarWidgetVisualizationInfo
local GetZoneControlVisualizationInfo                                  = _G.C_UIWidgetManager.GetZoneControlVisualizationInfo
local issecretvalue                                                    = _G.issecretvalue

-- get double status bar widget visulalization info
function NS:GetDoubleStatusBarWidgetVisualizationInfo(widgetID)
	-- sanity checks?
	if (not widgetID or issecretvalue(widgetID)) then
		-- failed
		return nil
	end

	-- success
	return GetDoubleStatusBarWidgetVisualizationInfo(widgetID)
end

function NS:GetIconAndTextWidgetVisualizationInfo(widgetID)
	-- sanity checks?
	if (not widgetID or issecretvalue(widgetID)) then
		-- failed
		return nil
	end

	-- success
	return GetIconAndTextWidgetVisualizationInfo(widgetID)
end

-- get widget data
function NS:GetWidgetData(info)
	-- sanity checks?
	if (not info or issecretvalue(info.widgetType) or issecretvalue(info.widgetID)) then
		-- failed
		return nil
	end

	-- 0: IconAndText?
	if (info.widgetType == Enum.UIWidgetVisualizationType.IconAndText) then
		-- get icon and text info
		return GetIconAndTextWidgetVisualizationInfo(info.widgetID)
	-- 1: CaptureBar?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.CaptureBar) then
		-- get capture bar info
		return GetCaptureBarWidgetVisualizationInfo(info.widgetID)
	-- 2: StatusBar?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.StatusBar) then
		-- get status bar info
		return GetStatusBarWidgetVisualizationInfo(info.widgetID)
	-- 3: DoubleStatusBar?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.DoubleStatusBar) then
		-- get double status bar info
		return GetDoubleStatusBarWidgetVisualizationInfo(info.widgetID)
	-- 4: IconTextAndBackground?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.IconTextAndBackground) then
		-- get icon text and background info
		return GetIconTextAndBackgroundWidgetVisualizationInfo(info.widgetID)
	-- 5: DoubleIconAndText?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.DoubleIconAndText) then
		-- get double icon and text info
		return GetDoubleIconAndTextWidgetVisualizationInfo(info.widgetID)
	-- 6: StackedResourceTracker?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.StackedResourceTracker) then
		-- get stacked resource tracker info
		return GetStackedResourceTrackerWidgetVisualizationInfo(info.widgetID)
	-- 7 : IconTextAndCurrencies?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.IconTextAndCurrencies) then
		-- get icon text and currencies info
		return GetIconTextAndCurrenciesWidgetVisualizationInfo(info.widgetID)
	-- 8: TextWithState?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.TextWithState) then
		-- get text width state info
		return GetTextWithStateWidgetVisualizationInfo(info.widgetID)
	-- 9: HorizontalCurrencies?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.HorizontalCurrencies) then
		--a get horizontal currencies info
		return GetHorizontalCurrenciesWidgetVisualizationInfo(info.widgetID)
	-- 10: BulletTextList?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.BulletTextList) then
		-- get bullet text lists info
		return GetBulletTextListWidgetVisualizationInfo(info.widgetID)
	-- 11: ScenarioHeaderCurrenciesAndBackground?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.ScenarioHeaderCurrenciesAndBackground) then
		-- get scenario header currencies and background info
		return GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo(info.widgetID)
	-- 12: TextureAndText?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.TextureAndText) then
		-- get texture and text info
		return GetTextureAndTextVisualizationInfo(info.widgetID)
	-- 13: SpellDisplay?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.SpellDisplay) then
		-- get spell display info
		return GetSpellDisplayVisualizationInfo(info.widgetID)
	-- 14: DoubleStateIconRow?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.DoubleStateIconRow) then
		-- get double state icon raw info
		return GetDoubleStateIconRowVisualizationInfo(info.widgetID)
	-- 15: TextureAndTextRow?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.TextureAndTextRow) then
		-- get texture and text row info
		return GetTextureAndTextRowVisualizationInfo(info.widgetID)
	-- 16: ZoneControl?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.ZoneControl) then
		-- get zone control info
		return GetZoneControlVisualizationInfo(info.widgetID)
	-- 17: CaptureZone?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.CaptureZone) then
		-- get capture zone info
		return GetCaptureZoneVisualizationInfo(info.widgetID)
	-- 18: TextureWithAnimation?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.TextureWithAnimation) then
		-- get texture with animation info
		return GetTextureWithAnimationVisualizationInfo(info.widgetID)
	-- 19: DiscreteProgressSteps?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.DiscreteProgressSteps) then
		-- get discrete progress steps info
		return GetDiscreteProgressStepsVisualizationInfo(info.widgetID)
	-- 20: ScenarioHeaderTimer?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.ScenarioHeaderTimer) then
		-- get scenario header timer info
		return GetScenarioHeaderTimerWidgetVisualizationInfo(info.widgetID)
	-- 21: TextColumnRow?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.TextColumnRow) then
		-- get text column row info
		return GetTextColumnRowVisualizationInfo(info.widgetID)
	-- 22: Spacer?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.Spacer) then
		-- get spacer info
		return GetSpacerVisualizationInfo(info.widgetID)
	-- 23: UnitPowerBar?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.UnitPowerBar) then
		-- get unit power bar info
		return GetUnitPowerBarWidgetVisualizationInfo(info.widgetID)
	-- 24: FillUpFrames?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.FillUpFrames) then
		-- get fill up frames info
		return GetFillUpFramesWidgetVisualizationInfo(info.widgetID)
	-- 25: TextWithSubtext?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.TextWithSubtext) then
		-- get text with subtext info
		return GetTextWithSubtextWidgetVisualizationInfo(info.widgetID)
	-- 26: MapPinAnimation?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.MapPinAnimation) then
		-- get map pin animation info
		return GetMapPinAnimationWidgetVisualizationInfo(info.widgetID)
	-- 27: ItemDisplay?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.ItemDisplay) then
		-- get item display info
		return GetItemDisplayVisualizationInfo(info.widgetID)
	-- 28: TugOfWar?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.TugOfWar) then
		-- get tug of war info
		return GetTugOfWarWidgetVisualizationInfo(info.widgetID)
	-- 29: ScenarioHeaderDelves?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.ScenarioHeaderDelves) then
		-- get scenario header delves info
		return GetScenarioHeaderDelvesWidgetVisualizationInfo(info.widgetID)
	-- 30: ButtonHeader?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.ButtonHeader) then
		-- get button header info
		return GetButtonHeaderWidgetVisualizationInfo(info.widgetID)
	-- 31: PreyHuntProgress?
	elseif (info.widgetType == Enum.UIWidgetVisualizationType.PreyHuntProgress) then
		-- get prey hunt progress info
		return GetPreyHuntProgressWidgetVisualizationInfo(info.widgetID)
	else
		-- unknown
		return nil
	end
end
