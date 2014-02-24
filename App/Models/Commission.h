//
//  Commission.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 2/24/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Commission : NSObject

- (id)initWithAttributes:(NSDictionary *)attributes;

//{
//	"unpaid":[
//			  {
//				  "amount":"16.10",
//				  "rate":"70",
//				  "currency":"USD",
//				  "item":"PDF Invoices"
//			  },
//			  {
//				  "amount":"12.51",
//				  "rate":"12.51",
//				  "currency":"USD",
//				  "item":"Marketplace Bundle"
//			  },
//			  {
//				  "amount":"12.51",
//				  "rate":"12.51",
//				  "currency":"USD",
//				  "item":"Marketplace Bundle"
//			  },
//			  {
//				  "amount":"22.40",
//				  "rate":"70",
//				  "currency":"USD",
//				  "item":"Reviews"
//			  },
//			  {
//				  "amount":"17.92",
//				  "rate":"70",
//				  "currency":"usd",
//				  "item":"Reviews"
//			  },
//			  {
//				  "amount":"35.64",
//				  "rate":"7.2",
//				  "currency":"usd",
//				  "item":"Core Extensions Bundle"
//			  },
//			  {
//				  "amount":"12.51",
//				  "rate":"12.51",
//				  "currency":"USD",
//				  "item":"Marketplace Bundle"
//			  },
//			  {
//				  "amount":"12.51",
//				  "rate":"12.51",
//				  "currency":"USD",
//				  "item":"Marketplace Bundle"
//			  },
//			  {
//				  "amount":"12.51",
//				  "rate":"12.51",
//				  "currency":"USD",
//				  "item":"Marketplace Bundle"
//			  },
//			  {
//				  "amount":"12.51",
//				  "rate":"12.51",
//				  "currency":"usd",
//				  "item":"Marketplace Bundle"
//			  },
//			  {
//				  "amount":"16.10",
//				  "rate":"70",
//				  "currency":"USD",
//				  "item":"PDF Invoices"
//			  },
//			  {
//				  "amount":"16.10",
//				  "rate":"70",
//				  "currency":"USD",
//				  "item":"PDF Invoices"
//			  },
//			  {
//				  "amount":"12.51",
//				  "rate":"12.51",
//				  "currency":"USD",
//				  "item":"Marketplace Bundle"
//			  },
//			  {
//				  "amount":"22.40",
//				  "rate":"70",
//				  "currency":"USD",
//				  "item":"Reviews"
//			  },
//			  {
//				  "amount":"12.51",
//				  "rate":"12.51",
//				  "currency":"usd",
//				  "item":"Marketplace Bundle"
//			  },
//			  {
//				  "amount":"12.51",
//				  "rate":"12.51",
//				  "currency":"usd",
//				  "item":"Marketplace Bundle"
//			  },
//			  {
//				  "amount":"12.51",
//				  "rate":"12.51",
//				  "currency":"usd",
//				  "item":"Marketplace Bundle"
//			  },
//			  {
//				  "amount":"12.51",
//				  "rate":"12.51",
//				  "currency":"usd",
//				  "item":"Marketplace Bundle"
//			  },
//			  {
//				  "amount":"17.92",
//				  "rate":"70",
//				  "currency":"USD",
//				  "item":"Reviews"
//			  },
//			  {
//				  "amount":"16.10",
//				  "rate":"70",
//				  "currency":"USD",
//				  "item":"PDF Invoices"
//			  },
//			  {
//				  "amount":"12.51",
//				  "rate":"12.51",
//				  "currency":"usd",
//				  "item":"Marketplace Bundle"
//			  },
//			  {
//				  "amount":"12.51",
//				  "rate":"12.51",
//				  "currency":"USD",
//				  "item":"Marketplace Bundle"
//			  },
//			  {
//				  "amount":"12.51",
//				  "rate":"12.51",
//				  "currency":"usd",
//				  "item":"Marketplace Bundle"
//			  },
//			  {
//				  "amount":"16.10",
//				  "rate":"70",
//				  "currency":"usd",
//				  "item":"PDF Invoices"
//			  },
//			  {
//				  "amount":"16.10",
//				  "rate":"70",
//				  "currency":"USD",
//				  "item":"PDF Invoices"
//			  },
//			  {
//				  "amount":"12.51",
//				  "rate":"12.51",
//				  "currency":"USD",
//				  "item":"Marketplace Bundle"
//			  },
//			  {
//				  "amount":"12.51",
//				  "rate":"12.51",
//				  "currency":"USD",
//				  "item":"Marketplace Bundle"
//			  },
//			  {
//				  "amount":"28.70",
//				  "rate":"70",
//				  "currency":"USD",
//				  "item":"PDF Invoices"
//			  },
//			  {
//				  "amount":"12.51",
//				  "rate":"12.51",
//				  "currency":"usd",
//				  "item":"Marketplace Bundle"
//			  },
//			  {
//				  "amount":"16.10",
//				  "rate":"70",
//				  "currency":"USD",
//				  "item":"PDF Invoices"
//			  }
//			  ],
//	"paid":[
//			{
//				"amount":"28.70",
//				"rate":"70",
//				"currency":"USD",
//				"item":"PDF Invoices"
//			},
//			{
//				"amount":"12.51",
//				"rate":"12.51",
//				"currency":"USD",
//				"item":"Marketplace Bundle"
//			},
//			{
//				"amount":"12.51",
//				"rate":"12.51",
//				"currency":"USD",
//				"item":"Marketplace Bundle"
//			},
//			{
//				"amount":"12.51",
//				"rate":"12.51",
//				"currency":"usd",
//				"item":"Marketplace Bundle"
//			},
//			{
//				"amount":"12.88",
//				"rate":"70",
//				"currency":"usd",
//				"item":"PDF Invoices"
//			},
//			{
//				"amount":"12.51",
//				"rate":"12.51",
//				"currency":"usd",
//				"item":"Marketplace Bundle"
//			},
//			{
//				"amount":"12.51",
//				"rate":"12.51",
//				"currency":"USD",
//				"item":"Marketplace Bundle"
//			},
//			{
//				"amount":"16.10",
//				"rate":"70",
//				"currency":"usd",
//				"item":"PDF Invoices"
//			},
//			{
//				"amount":"16.10",
//				"rate":"70",
//				"currency":"USD",
//				"item":"PDF Invoices"
//			},
//			{
//				"amount":"12.51",
//				"rate":"12.51",
//				"currency":"USD",
//				"item":"Marketplace Bundle"
//			},
//			{
//				"amount":"31.50",
//				"rate":"70",
//				"currency":"usd",
//				"item":"Lattice Theme"
//			},
//			{
//				"amount":"16.10",
//				"rate":"70",
//				"currency":"usd",
//				"item":"PDF Invoices"
//			},
//			{
//				"amount":"12.51",
//				"rate":"12.51",
//				"currency":"usd",
//				"item":"Marketplace Bundle"
//			},
//			{
//				"amount":"35.64",
//				"rate":"7.2",
//				"currency":"usd",
//				"item":"Core Extensions Bundle"
//			},
//			{
//				"amount":"12.51",
//				"rate":"12.51",
//				"currency":"USD",
//				"item":"Marketplace Bundle"
//			},
//			{
//				"amount":"31.50",
//				"rate":"70",
//				"currency":"USD",
//				"item":"Lattice Theme"
//			},
//			{
//				"amount":"31.50",
//				"rate":"70",
//				"currency":"USD",
//				"item":"Lattice Theme"
//			},
//			{
//				"amount":"17.92",
//				"rate":"70",
//				"currency":"usd",
//				"item":"Reviews"
//			},
//			{
//				"amount":"12.88",
//				"rate":"70",
//				"currency":"usd",
//				"item":"PDF Invoices"
//			},
//			{
//				"amount":"12.51",
//				"rate":"12.51",
//				"currency":"USD",
//				"item":"Marketplace Bundle"
//			},
//			{
//				"amount":"12.51",
//				"rate":"12.51",
//				"currency":"USD",
//				"item":"Marketplace Bundle"
//			},
//			{
//				"amount":"12.51",
//				"rate":"12.51",
//				"currency":"USD",
//				"item":"Marketplace Bundle"
//			},
//			{
//				"amount":"16.10",
//				"rate":"70",
//				"currency":"usd",
//				"item":"PDF Invoices"
//			},
//			{
//				"amount":"12.51",
//				"rate":"12.51",
//				"currency":"USD",
//				"item":"Marketplace Bundle"
//			},
//			{
//				"amount":"16.10",
//				"rate":"70",
//				"currency":"USD",
//				"item":"PDF Invoices"
//			},
//			{
//				"amount":"12.51",
//				"rate":"12.51",
//				"currency":"usd",
//				"item":"Marketplace Bundle"
//			},
//			{
//				"amount":"12.88",
//				"rate":"70",
//				"currency":"USD",
//				"item":"PDF Invoices"
//			},
//			{
//				"amount":"22.40",
//				"rate":"70",
//				"currency":"usd",
//				"item":"Reviews"
//			},
//			{
//				"amount":"12.51",
//				"rate":"12.51",
//				"currency":"USD",
//				"item":"Marketplace Bundle"
//			},
//			{
//				"amount":"16.10",
//				"rate":"70",
//				"currency":"USD",
//				"item":"PDF Invoices"
//			}
//			],
//	"totals":{
//		"unpaid":1286.22,
//		"paid":5862.54464
//	}

@end
