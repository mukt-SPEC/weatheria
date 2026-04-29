import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

Widget getWeatherIcon(int isDay, {required int weathercode}) {
  switch (weathercode) {
    case 1000:
      return isDay == 1
          ? const PhosphorIcon(PhosphorIconsRegular.sun)
          : const PhosphorIcon(PhosphorIconsRegular.moon);
    case 1003:
      return const PhosphorIcon(PhosphorIconsRegular.cloudSun);
    case 1006:
    case 1009:
      return const PhosphorIcon(PhosphorIconsRegular.cloud);
    case 1030:
    case 1135:
    case 1147:
      return const PhosphorIcon(PhosphorIconsRegular.cloudFog);
    case 1063:
    case 1150:
    case 1153:
    case 1180:
    case 1183:
    case 1186:
    case 1189:
    case 1192:
    case 1195:
    case 1198:
    case 1201:
    case 1240:
    case 1243:
    case 1246:
      return const PhosphorIcon(PhosphorIconsRegular.cloudRain);
    case 1066:
    case 1114:
    case 1117:
    case 1210:
    case 1213:
    case 1216:
    case 1219:
    case 1222:
    case 1225:
    case 1237:
    case 1255:
    case 1258:
      return const PhosphorIcon(PhosphorIconsRegular.cloudSnow);
    case 1069:
    case 1204:
    case 1207:
    case 1249:
    case 1252:
    case 1261:
    case 1264:
      return const PhosphorIcon(PhosphorIconsRegular.cloudSnow);
    case 1072:
    case 1168:
    case 1171:
      return const PhosphorIcon(PhosphorIconsRegular.cloudRain);
    case 1087:
    case 1273:
    case 1276:
    case 1279:
    case 1282:
      return const PhosphorIcon(PhosphorIconsRegular.cloudLightning);
    default:
      return const PhosphorIcon(PhosphorIconsRegular.sunHorizon);
  }
}
