//
//  HelloWorldLayer.mm
//  ggj13
//
//  Created by Brennon Redmyer on 1/25/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "QueryCallback.h"



@implementation HelloWorldLayer {
    BOOL isGrabbed;
    BOOL hasBeenTouched;
}
+ (id)scene {
    CCScene *scene = [CCScene node];
    HelloWorldLayer *layer = [HelloWorldLayer node];
    [scene addChild:layer];
    return scene;
}
- (id)init {
    self = [super init];
    if (self) {
        [[CCDirector sharedDirector] setDisplayStats:NO];
        // mousejoin nil
        _mouseJoint = nil;
        // enable touch
        self.isTouchEnabled = YES;
        CGSize winSize = [CCDirector sharedDirector].winSize;
        // create sprite and add it to the layer
//        _block = [CCSprite spriteWithFile:@"block_base.png"];
//        _block.position = ccp(100, 300);
        // create a world
        b2Vec2 gravity = b2Vec2(0.0f, -8.0f);
        _world = new b2World(gravity);
        // create edges around the entire screen
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0, 0);
        b2Body *groundBody = _world->CreateBody(&groundBodyDef);
        b2EdgeShape groundEdge;
        b2FixtureDef boxShapeDef;
        boxShapeDef.shape = &groundEdge;
        // wall definitions
        groundEdge.Set(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO, 0));
        groundBody->CreateFixture(&boxShapeDef);
        groundEdge.Set(b2Vec2(0, 0), b2Vec2(0, winSize.height/PTM_RATIO));
        groundBody->CreateFixture(&boxShapeDef);
        groundEdge.Set(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
        groundBody->CreateFixture(&boxShapeDef);
        groundEdge.Set(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 0));
        groundBody->CreateFixture(&boxShapeDef);
//        [self addLeftBlocks];
//        [self addRightBlocks];
        [self addTopBlocks];
        [self schedule:@selector(updateBlock:) interval:3.0f];
        [self schedule:@selector(tick:)];
        
        //Set up sprite
        GLESDebugDraw gGLESDebugDraw;
	/*
     // --unComment Code below to check body collision/shape whatever.
        [self addChild:[BoxDebugLayer debugLayerWithWorld:_world ptmRatio:PTM_RATIO] z:10000];
     */
        
#if 1
		// Use batch node. Faster        
        CCSpriteBatchNode *parent1 = [CCSpriteBatchNode batchNodeWithFile:@"HeartAqua.png" capacity:100];
		heartSpriteTexture_ = [parent1 texture];
        
        //volumesprite
        volumeMeterSprite = [CCSprite spriteWithFile:@"Volumebar_black.png"];
        volumeMeterSprite.position = ccp(160, 25);
        [self addChild:volumeMeterSprite z:2 tag:0];
#else
        heartSpriteTexture_ = [[CCTextureCache sharedTextureCache] addImage:@"HeartAqua.png"];
		CCNode *parent1 = [CCNode node];
#endif
        //heart
        [self addChild:parent1 z:0 tag:kTagheartParentNode];
        [self addHeartSpriteAtPosition:ccp(winSize.width/2, winSize.height/2)];
        
     }
    return self;
}
- (void)draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
    
    b2Draw *debugDraw = new GLESDebugDraw(PTM_RATIO);
    
    debugDraw->SetFlags(GLESDebugDraw::e_shapeBit);
    
    _world->SetDebugDraw(debugDraw);
    
	_world->DrawDebugData();
	
	kmGLPopMatrix();
}
- (void)addHeartSpriteAtPosition:(CGPoint)p
{
	CCLOG(@"Add heartsprite %0.2f x %02.f",p.x,p.y);
    
    //heart
    CCNode *parent1 = [self getChildByTag:kTagheartParentNode];
	
    //heart
    PhysicsSprite *heartsSprite = [PhysicsSprite spriteWithTexture:heartSpriteTexture_ rect:CGRectMake(0, 0, 128, 128)];
    
	
    //heart
    [parent1 addChild:heartsSprite];
	
    
    //heart
    heartsSprite.position = ccp(p.x, p.y);
    
    //heart
    b2BodyDef heartBodyDef;
    heartBodyDef.userData = heartsSprite;
	heartBodyDef.type = b2_staticBody;
	heartBodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *heartBody = _world->CreateBody(&heartBodyDef);
    
    //heart shapes
    //box
    b2PolygonShape heartdynamicBox;
	heartdynamicBox.SetAsBox(.30f, .30f);//These are mid points for our 1m box
	
    //any shape we make it
    b2PolygonShape shape;
    int num = 6;
    b2Vec2 verts[] = {
        //middle point
        b2Vec2(0.0f*heartsSprite.scale / PTM_RATIO, 30.8f*heartsSprite.scale / PTM_RATIO),
        //left corner top
        b2Vec2(-35.2f*heartsSprite.scale / PTM_RATIO, 45.0f*heartsSprite.scale / PTM_RATIO),
        //bottom left corner
        b2Vec2(-60.0f*heartsSprite.scale / PTM_RATIO, -01.1f*heartsSprite.scale / PTM_RATIO),
        //center bottom
        b2Vec2(02.0f*heartsSprite.scale / PTM_RATIO, -62.0f*heartsSprite.scale / PTM_RATIO),
        //bottom right corner
        b2Vec2(60.0f*heartsSprite.scale / PTM_RATIO, -01.1f*heartsSprite.scale / PTM_RATIO),
        //top right corner
        b2Vec2(35.2f*heartsSprite.scale / PTM_RATIO, 45.0f*heartsSprite.scale / PTM_RATIO)
    };
    
    shape.Set(verts, num);
    b2FixtureDef heartFixtureDef;
	heartFixtureDef.shape = &shape;
	heartFixtureDef.density = 1.0f;
	heartFixtureDef.friction = 0.3f;
    heartFixtureDef.restitution = 0.4;
	heartBody->CreateFixture(&heartFixtureDef);
    [heartsSprite setPhysicsBody:heartBody];
}
- (void)addTopBlocks {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CCSprite *tempSprite = [CCSprite spriteWithFile:@"block_base.png"];
    int imageWidth = tempSprite.contentSize.width;
    int imageHeight = tempSprite.contentSize.height;
    int numBlocks = winSize.width / imageWidth;
    self.topBlockArray = [NSMutableArray arrayWithCapacity:numBlocks];
    self.topMissingArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < numBlocks; i++) {
        _body = nil;
        _block = nil;
        _block = [CCSprite spriteWithFile:@"block_base.png"];
        _block.position = CGPointMake(_block.contentSize.width * i+_block.contentSize.width * 0.5f, winSize.height - _block.contentSize.height/2);
        
        // create block body and shape
        b2BodyDef blockBodyDef;
        blockBodyDef.type = b2_staticBody;
        blockBodyDef.position.Set(_block.position.x/PTM_RATIO, _block.position.y/PTM_RATIO);
        blockBodyDef.userData = _block;
        _body = _world->CreateBody(&blockBodyDef);
        _block.userData = _body;
        // modified for box shape instead of circle (from Ray Wenderlich's tutorial series)
        b2PolygonShape box;
        box.SetAsBox(16/PTM_RATIO, 16/PTM_RATIO);
        b2FixtureDef blockShapeDef;
        blockShapeDef.shape = &box;
        blockShapeDef.density = 1.0f;
        blockShapeDef.friction = 0.2f;
        blockShapeDef.restitution = 0;
        _body->CreateFixture(&blockShapeDef);
        [self.topBlockArray addObject:_block];
        // [self.topMissingArray addObject:futureBlock];
        [self addChild:_block z:0];
    }
}
- (void)addLeftBlocks {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CCSprite *tempSprite = [CCSprite spriteWithFile:@"block_base.png"];
    int imageWidth = tempSprite.contentSize.width;
    int imageHeight = tempSprite.contentSize.height;
    int numBlocks = winSize.width / imageWidth;
    _leftBlockArray = [NSMutableArray arrayWithCapacity:numBlocks];
    for (int i = 0; i < numBlocks; i++) {
        _body = nil;
        _block = nil;
        _block = [CCSprite spriteWithFile:@"block_base.png"];
        _block.position = CGPointMake(imageWidth/2, (winSize.height - _block.contentSize.height - (_block.contentSize.height * i+_block.contentSize.height * 0.5f)));
        // create block body and shape
        b2BodyDef blockBodyDef;
        blockBodyDef.type = b2_staticBody;
        blockBodyDef.position.Set(_block.position.x/PTM_RATIO, _block.position.y/PTM_RATIO);
        blockBodyDef.userData = _block;
        _body = _world->CreateBody(&blockBodyDef);
        // modified for box shape instead of circle (from Ray Wenderlich's tutorial series)
        b2PolygonShape box;
        box.SetAsBox(16/PTM_RATIO, 16/PTM_RATIO);
        b2FixtureDef blockShapeDef;
        blockShapeDef.shape = &box;
        blockShapeDef.density = 1.0f;
        blockShapeDef.friction = 0.2f;
        blockShapeDef.restitution = 0;
        _body->CreateFixture(&blockShapeDef);
        [self addChild:_block];
    }
}
- (void)addRightBlocks {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CCSprite *tempSprite = [CCSprite spriteWithFile:@"block_base.png"];
    int imageWidth = tempSprite.contentSize.width;
    int imageHeight = tempSprite.contentSize.height;
    int numBlocks = winSize.width/ imageWidth;
    _rightBlockArray = [NSMutableArray arrayWithCapacity:numBlocks];
    for (int i = 0; i < numBlocks; i++) {
        _body = nil;
        _block = nil;
        _block = [CCSprite spriteWithFile:@"block_base.png"];
        _block.position = CGPointMake(winSize.width - imageWidth/2, (winSize.height - _block.contentSize.height - (_block.contentSize.height * i+_block.contentSize.height * 0.5f)));
        // create block body and shape
        b2BodyDef blockBodyDef;
        blockBodyDef.type = b2_staticBody;
        blockBodyDef.position.Set(_block.position.x/PTM_RATIO, _block.position.y/PTM_RATIO);
        blockBodyDef.userData = _block;
        _body = _world->CreateBody(&blockBodyDef);
        // modified for box shape instead of circle (from Ray Wenderlich's tutorial series)
        b2PolygonShape box;
        box.SetAsBox(16/PTM_RATIO, 16/PTM_RATIO);
        b2FixtureDef blockShapeDef;
        blockShapeDef.shape = &box;
        blockShapeDef.density = 1.0f;
        blockShapeDef.friction = 0.2f;
        blockShapeDef.restitution = 0;
        _body->CreateFixture(&blockShapeDef);
        [self addChild:_block];
    }
}
- (void)updateBlock:(ccTime) dt {
    CCLOG(@"array count: %d", self.topBlockArray.count);
    [self chooseBlock:dt withArray:self.topBlockArray];
}
- (void)chooseBlock:(ccTime)dt withArray:(NSMutableArray *)blockArray {
    int numItems = blockArray.count;
    int randIndex = arc4random() % numItems;
    NSMutableArray *missingArray;
    if (blockArray == self.topBlockArray) {
        missingArray = self.topMissingArray;
    }
    CCSprite *block = [CCSprite spriteWithFile:@"block_base.png"];
    CCSprite *futureBlock = [CCSprite spriteWithFile:@"block_base.png"];
    for (int i = 0; i < numItems; i++) {
        // holy shit, pissssss
        if (i == randIndex) {
            block = [blockArray objectAtIndex:i];
            b2Body* body = (b2Body *)block.userData;
            if (body != nil)
            {
                futureBlock.color = ccc3(100, 100, 100);
                futureBlock.position = block.position;
                [missingArray addObject:futureBlock];
                CCLOG(@"topmissing count: %d", missingArray.count);
                [self addChild:futureBlock z:-1];
                body->SetType(b2_dynamicBody);
                [blockArray removeObject:block];
                break;
            }
        }
    }
}
- (void)tick:(ccTime)dt {
    _world->Step(dt, 10, 10);
    for (b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *blockData = (CCSprite *)b->GetUserData();
            blockData.position = ccp(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
            blockData.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }
    }
    [self checkCollision];
}
- (void)checkCollision {
    int index = -1;
    for (CCSprite *block in self.topMissingArray) {
        CGRect rect = block.boundingBox;
        self.snapPoint = block.position;
        /* block.color = ccc3(100, 100, 100); */
        if (self.grabbedBody != nil) {
            CCSprite *grabbedBlockSprite = (CCSprite*)self.grabbedBody->GetUserData();
            CGRect rect2 = grabbedBlockSprite.boundingBox;
            if (CGRectIntersectsRect(rect, rect2) && hasBeenTouched) {
                hasBeenTouched = NO;
                CCLOG(@"HIT FLING!!!");
                self.grabbedBody->SetTransform(b2Vec2(block.position.x/PTM_RATIO, block.position.y/PTM_RATIO), 0);
                self.grabbedBody->SetType(b2_staticBody);
                block.userData = self.grabbedBody;
                [self.topBlockArray addObject:block];
                index = [self.topMissingArray indexOfObject:block];
            }
        }
    }
    [self deleteObjects:index];
}
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* myTouch = [touches anyObject];
	CGPoint location = [myTouch locationInView: [myTouch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	location = [self convertToNodeSpace:location];
    
	_mouseWorld.Set(ptm(location.x), ptm(location.y));
	if (_mouseJoint != NULL)
	{
		return;
	}
    
	b2AABB aabb;
	b2Vec2 d = b2Vec2(0.001f, 0.001f);
	aabb.lowerBound = _mouseWorld - d;
	aabb.upperBound = _mouseWorld + d;
    
	// Query the world for overlapping shapes.
	QueryCallback callback(_mouseWorld);
	_world->QueryAABB(&callback, aabb);
    
	if (callback.m_fixture)
	{
        isGrabbed = YES;
        hasBeenTouched = YES;
        CCLOG(@"isGrabbed = %d", isGrabbed);
		b2BodyDef bodyDef;
		b2Body* groundBody = _world->CreateBody(&bodyDef);
        
		b2Body* bodyz = callback.m_fixture->GetBody();
        self.grabbedBody = bodyz;
        CCLOG(@"Grabbed body!");
		bodyz->SetAwake(true);
        
		b2MouseJointDef md;
		md.bodyA = groundBody;
		md.bodyB = bodyz;
		md.target = _mouseWorld;
		md.maxForce = 1000.0f * bodyz->GetMass();
        
		_mouseJoint = (b2MouseJoint*)_world->CreateJoint(&md);
	}
}
- (void)ccTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch* myTouch = [touches anyObject];
	CGPoint location = [myTouch locationInView: [myTouch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	location = [self convertToNodeSpace:location];
    int index = -1;
	_mouseWorld.Set(ptm(location.x), ptm(location.y));
    
	if (_mouseJoint)
	{
		_mouseJoint->SetTarget(_mouseWorld);
	}
    for (CCSprite *block in self.topMissingArray) {
        CGRect rect = block.boundingBox;
        if (CGRectContainsPoint(rect, location)) {
            CCLOG(@"HIT!!!");
            self.snapPoint = block.position;
            /* block.color = ccc3(100, 100, 100); */
            CCSprite *grabbedBlockSprite = (CCSprite*)self.grabbedBody->GetUserData();
            CGRect rect2 = grabbedBlockSprite.boundingBox;
            if (CGRectIntersectsRect(rect, rect2) && hasBeenTouched) {
                hasBeenTouched = NO;
                self.grabbedBody->SetTransform(b2Vec2(block.position.x/PTM_RATIO, block.position.y/PTM_RATIO), 0);
                self.grabbedBody->SetType(b2_staticBody);
                block.userData = self.grabbedBody;
                [self.topBlockArray addObject:block];
                index = [self.topMissingArray indexOfObject:block];
            }
        }
    }
    [self deleteObjects:index];
}
- (void)deleteObjects:(int)index {
    if (index != -1) {
        [self.topMissingArray removeObjectAtIndex:index];
        CCLOG(@"topmissingarray count: %d", self.topMissingArray.count);
    }
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* myTouch = [touches anyObject];
	CGPoint location = [myTouch locationInView: [myTouch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	location = [self convertToNodeSpace:location];
	[self ccTouchesCancelled:touches withEvent:event];
    
}
- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	if (_mouseJoint)
	{
		_world->DestroyJoint(_mouseJoint);
		_mouseJoint = NULL;
        if (isGrabbed) {
            isGrabbed = NO;
        }
        //CCLOG(@"%@", self.grabbedBody->GetUserData());
        CCLOG(@"Released body!");
        CCLOG(@"isGrabbed: %d", isGrabbed);
	}
}
//- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    // switch bodydef to dynamic and back
////    CCLOG(@"Touch!!");
////    for (b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
////        if (b->GetType() == b2_dynamicBody) {
////            CCLOG(@"Bodies dynamic, going static...");
////            b->SetType(b2_staticBody);
////        } else {
////            CCLOG(@"Bodies static, going dynamic...");
////            b->SetType(b2_dynamicBody);
////        }
////    }
//}
@end