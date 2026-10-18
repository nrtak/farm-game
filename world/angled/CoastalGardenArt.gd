extends RefCounted
const REGIONS=[Rect2(0,90,425,405),Rect2(430,105,380,390),Rect2(815,85,365,410),Rect2(1180,0,356,495),Rect2(0,520,435,480),Rect2(435,650,420,345),Rect2(855,515,290,480),Rect2(1170,650,366,350)]
static func texture(index:int)->AtlasTexture:
 var t=AtlasTexture.new();t.atlas=load("res://world/angled/coastal-gardens-v1.png");t.region=REGIONS[index];return t
