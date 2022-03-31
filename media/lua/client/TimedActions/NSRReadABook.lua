require "TimedActions/ISReadABook"

growthPerTime = 6.1553e-6
boredomGrowthPerTime = 2.0833e-4

NSROVERWRITE_ISReadABook_update = ISReadABook.update
function ISReadABook:update()

	NSROVERWRITE_ISReadABook_update(self)
	
	local deltaAmount =  (self:getJobDelta() - self.lastDelta)

	ISReadABook.NSR_addAdditional(self, deltaAmount)
	self.lastDelta = self:getJobDelta()
	
end

NSROVERWRITE_ISReadABook_perform = ISReadABook.perform
function ISReadABook:perform()
	local remainingDelta = 1 - self.lastDelta
	ISReadABook.NSR_addAdditional(self, remainingDelta)
	
	NSROVERWRITE_ISReadABook_perform(self)
end

NSROVERWRITE_ISReadABook_start = ISReadABook.start
function ISReadABook:start()
	NSROVERWRITE_ISReadABook_start(self)
	
	if self.startPage then
		self.lastDelta = self.startPage / self.item:getNumberOfPages()
	end
end


NSROVERWRITE_ISReadABook_new = ISReadABook.new
function ISReadABook:new(player, item, time)
	
	local o = NSROVERWRITE_ISReadABook_new(self, player, item, time)
	
	o.readSpeedModifier =  SandboxVars.NicocokoSpeedReading.ReadSpeedMultiplier

	local speedUpMaxTime =  math.ceil(o.maxTime / o.readSpeedModifier)
	local timeDifference = o.maxTime - speedUpMaxTime
	
	local caloriesModifier = 1.0
	if(SandboxVars.NicocokoSpeedReading.IncreaseCalorieConsumption) then
		caloriesModifier = o.readSpeedModifier
	end

	local hungerMultiplier = 0.0
	if(SandboxVars.NicocokoSpeedReading.IncreaseHunger) then
		hungerMultiplier = 1.0
	end
	if(o.character:HasTrait("LightEater")) then
		hungerMultiplier = hungerMultiplier * 0.75
	end
	if(o.character:HasTrait("HeartyAppitite")) then
		hungerMultiplier = hungerMultiplier * 1.5
	end

	local thirstMultiplier = 0.0
	if(SandboxVars.NicocokoSpeedReading.IncreaseThirst) then
		thirstMultiplier = 1.0
	end
	if(o.character:HasTrait("LowThirst")) then
		thirstMultiplier = thirstMultiplier * 0.5
	end
	if(o.character:HasTrait("High Thirst")) then
		thirstMultiplier = thirstMultiplier * 2
	end
	
	local boredomMultiplier = 0.0
	if(SandboxVars.NicocokoSpeedReading.IncreaseBoredom) then
		boredomMultiplier = 1.0
	end
	
	o.caloriesModifier = o.caloriesModifier * caloriesModifier
	
	o.additionalHunger = timeDifference * growthPerTime * hungerMultiplier
	o.additionalThirst = timeDifference * growthPerTime * thirstMultiplier
	
	o.additionalBoredom = timeDifference * boredomGrowthPerTime * boredomMultiplier
	
	o.maxTime = speedUpMaxTime
	o.lastDelta = 0.0
	
	return o
end



ISReadABook.NSR_addAdditional = function(self, percentage)
	local stats = self.character:getStats()

	local hungerGain = percentage * self.additionalHunger
	local newHunger = stats:getHunger() + hungerGain
	stats:setHunger(newHunger)
	
	local thirstGain = percentage * self.additionalThirst
	local newThirst = stats:getThirst() + thirstGain
	stats:setThirst(newThirst)
	
	
	local bodyDamage = self.character:getBodyDamage()
	local boredomGain = percentage * self.additionalBoredom
	local newBoredom = bodyDamage:getBoredomLevel() + boredomGain
	bodyDamage:setBoredomLevel(newBoredom)
end