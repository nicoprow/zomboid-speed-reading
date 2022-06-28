require "TimedActions/ISReadABook"

defaultMultiplier = 20.0
hungerIncrease = 4.2424e-6
thirstIncrease = 3.9962e-6
boredomIncrease = 2.0833e-4
wellFedDurationLevel = 1440

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
	
	local readSpeedMultiplier =  SandboxVars.NicocokoSpeedReading.ReadSpeedMultiplier or defaultMultiplier
	local caloriesMultiplier = SandboxVars.NicocokoSpeedReading.CalorieConsumptionMultiplier or defaultMultiplier
	local hungerMultiplier= SandboxVars.NicocokoSpeedReading.HungerMultiplier or defaultMultiplier
	local thirstMultiplier = SandboxVars.NicocokoSpeedReading.ThirstMultiplier or defaultMultiplier
	local boredomMultiplier = SandboxVars.NicocokoSpeedReading.BoredomMultiplier or defaultMultiplier
	

	local speedUpMaxTime =  math.ceil(o.maxTime / readSpeedMultiplier)
	local timeDifference = o.maxTime - speedUpMaxTime
	
	local wellFedDuration = o.character:getMoodles():getMoodleLevel(MoodleType.FoodEaten) * wellFedDurationLevel
	local differenceHunger = o.maxTime - math.ceil(o.maxTime / hungerMultiplier) - wellFedDuration
	if(differenceHunger < 0) then
		differenceHunger = 0
	end
	
	local differenceThirst = o.maxTime - math.ceil(o.maxTime / thirstMultiplier)
	local differenceBoredom = o.maxTime - math.ceil(o.maxTime / boredomMultiplier)
	
	local hungerModifier = 1.0
	if(o.character:HasTrait("LightEater")) then
		hungerModifier = hungerModifier * 0.75
	end
	if(o.character:HasTrait("HeartyAppitite")) then
		hungerModifier = hungerModifier * 1.5
	end

	local thirstModifier = 1.0
	if(o.character:HasTrait("LowThirst")) then
		thirstModifier = thirstModifier * 0.5
	end
	if(o.character:HasTrait("HighThirst")) then
		thirstModifier = thirstModifier * 2
	end
	
	
	o.caloriesModifier = o.caloriesModifier * caloriesMultiplier
	o.additionalHunger = differenceHunger * hungerIncrease * hungerModifier
	o.additionalThirst = differenceThirst * thirstIncrease * thirstModifier
	o.additionalBoredom = differenceBoredom * boredomIncrease
	
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