local UIS = game:GetService("UserInputService")
local run = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local tween = game:GetService("TweenService")
local offset = CFrame.new(0, .8, 2)
local tweenInfo = TweenInfo.new(0.06, Enum.EasingStyle.Exponential)

local currentCameraMode = "PlayerChange"
local sens = 22
local cameraY = 0
local cameraZ  = 0
local gamepadY = 0
local gamepadZ = 0

while true do
	wait();
	if game.Players.LocalPlayer.Character then
		break;
	end
end
local player = game.Players.LocalPlayer
local character = player.Character
local cloneWHFolder = Instance.new("Folder", character)
cloneWHFolder.Name = "cloneClient"
local originalUpperTorso = character:FindFirstChild("UpperTorso")
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
local originalHead = character:FindFirstChild("Head")
originalHead.CanCollide = true
local humanoid = character:FindFirstChild("Humanoid")
originalHead.Transparency = 1
local upperTorso = originalUpperTorso:Clone()
upperTorso.Parent = cloneWHFolder
upperTorso.Transparency = 1
local head = originalHead:Clone()
local neck = head:FindFirstChild("Neck")
local waist = upperTorso:FindFirstChild("Waist")
local originalNeck = originalHead:FindFirstChild("Neck")
local originalWaist = originalUpperTorso:FindFirstChild("Waist")
neck.Part0 = upperTorso
head.Parent = cloneWHFolder
head.Transparency = 1
local root = character:FindFirstChild("HumanoidRootPart")
local body = Instance.new("BodyGyro", root)
body.MaxTorque = Vector3.new(0, 8000, 0)
body.D = 50;
body.P  =  90000
body.CFrame = CFrame.new(body.CFrame.Position) * CFrame.Angles(0,-math.rad(90),0)
local camera = game.Workspace.CurrentCamera
camera.FieldOfView = 50

humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
repeat
	camera.CameraType = Enum.CameraType.Scriptable
until camera.CameraType == Enum.CameraType.Scriptable

for i,v in pairs(character:GetChildren()) do
	if v:IsA("Accessory") then
		v:Destroy()
	elseif v:IsA("MeshPart") then
		v.CastShadow = false
	end
end

function SCamera(delta)
	if currentCameraMode == "PlayerChange" then
		local movementVector = workspace.Camera.CFrame:vectorToObjectSpace(humanoidRootPart.Velocity / math.max(humanoid.WalkSpeed, 0.01))
		UIS.MouseBehavior =  Enum.MouseBehavior.LockCenter
		cameraY += gamepadY
		cameraY = math.clamp(cameraY,  -26/1, 20/1)
		waist.C0 = CFrame.new(waist.C0.Position) * CFrame.Angles(math.rad(cameraY/2), 0, 0)
		neck.C0 = CFrame.new(neck.C0.Position) * CFrame.Angles(math.rad((cameraY)*1.8), 0, 0)
		body.CFrame *= CFrame.Angles(0, -math.rad((gamepadZ+cameraZ)/sens)*100, 0)
		tween:Create(camera, tweenInfo, {CFrame = CFrame.new(head.CFrame.Position)
			* camera.CFrame.Rotation:Lerp(root.BodyGyro.CFrame.Rotation
				* (neck.C0.Rotation * upperTorso.Waist.C0.Rotation)
				* CFrame.Angles(0,0,math.clamp(math.rad((((-movementVector.x*2+cameraZ+gamepadZ*3))/sens)*25), -.4, .4))
				*offset, 0.4)}):Play()
	else
		camera.CFrame = camera.CFrame:Lerp(originalHead.CFrame, 0.6)
		waist.C0 = CFrame.new(waist.C0.Position) * CFrame.Angles(0, 0, 0)
		neck.C0 = CFrame.new(neck.C0.Position) * CFrame.Angles(0, 0, 0)
		originalWaist.C0 = CFrame.new(waist.C0.Position) * CFrame.Angles(0, 0, 0)
		originalNeck.C0 = CFrame.new(neck.C0.Position) * CFrame.Angles(0, 0, 0)
	end
end
run.RenderStepped:Connect(SCamera)

function InputChanged(inputObject, GameProcessed)
	if currentCameraMode == "PlayerChange" then
		if inputObject.UserInputType == Enum.UserInputType.MouseMovement
			or inputObject.UserInputType == Enum.UserInputType.Touch and not GameProcessed
		then
			cameraY -= inputObject.Delta.y/sens
			cameraZ = inputObject.Delta.x/sens
			if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
				task.wait(0.1)
				cameraZ = 0
			end
		elseif inputObject.KeyCode == Enum.KeyCode.Thumbstick2 then
			gamepadY = (inputObject.Position.y/sens)*20
			gamepadZ = (inputObject.Position.x/sens)*15
		end
	end
end
UIS.InputChanged:Connect(InputChanged)
UIS.InputEnded:Connect(function(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.Touch or inputObject.KeyCode == Enum.KeyCode.Thumbstick2 then
		task.wait(0.1)
		cameraZ = 0
	end
end)
