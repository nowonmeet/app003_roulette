import 'dart:math' as math;
import 'package:flutter/material.dart';

class WeightedRandom
{
  var random = math.Random(); //ランダムを生成

  //渡された重み付け配列からIndexを得る
  static int GetRandomIndex(weightTable)
  {
  var random = math.Random(); //ランダムを生成
  var weightTable =[1000,59,20];
  var totalWeight = weightTable.reduce((a, b) => a + b);
  var value = random.nextInt(totalWeight);
//  random.Range(1, totalWeight + 1);
  var retIndex = -1;
  for (var i = 0; i < weightTable.length; ++i)
  {
  if (weightTable[i] >= value)
  {
  retIndex = i;
  break;
  }
  value -= weightTable[i];
  }
  return retIndex;
  }
}