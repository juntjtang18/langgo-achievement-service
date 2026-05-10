import fs from 'node:fs/promises';
import path from 'node:path';

const sourcePath = path.resolve(process.cwd(), '../langgo_strapi4/database/backup/langgo_full.sql');
const outputPath = path.resolve(process.cwd(), 'backup/strapi4-achievement-data.restore.sql');

function splitCopyLine(line) {
  return line.split('\t').map((value) => (value === '\\N' ? null : value));
}

function parseCopyBlock(sql, tableName) {
  const marker = `COPY public.${tableName} `;
  const start = sql.indexOf(marker);
  if (start === -1) {
    throw new Error(`COPY block not found for ${tableName}`);
  }

  const dataStart = sql.indexOf('\n', start) + 1;
  const endMarker = '\n\\.\n';
  const end = sql.indexOf(endMarker, dataStart);
  if (end === -1) {
    throw new Error(`COPY block terminator not found for ${tableName}`);
  }

  return sql
    .slice(dataStart, end)
    .trim()
    .split('\n')
    .filter(Boolean)
    .map(splitCopyLine);
}

function sqlString(value) {
  if (value == null) {
    return 'NULL';
  }

  return `'${String(value).replaceAll("'", "''")}'`;
}

function sqlNumber(value) {
  if (value == null || value === '') {
    return 'NULL';
  }

  return String(Number(value));
}

function sqlBoolean(value) {
  if (value == null) {
    return 'NULL';
  }

  return value === 't' ? 'TRUE' : 'FALSE';
}

function emitValues(rows, mapRow) {
  return rows.map((row) => `  (${mapRow(row).join(', ')})`).join(',\n');
}

function setvalSql(table, rows) {
  const maxId = rows.reduce((max, row) => Math.max(max, Number(row.id)), 0);
  return `SELECT setval(pg_get_serial_sequence('{{SCHEMA}}.${table}', 'id'), ${maxId}, true);`;
}

const sql = await fs.readFile(sourcePath, 'utf8');

const achievementRows = parseCopyBlock(sql, 'as_achievements').map((row) => ({
  id: Number(row[0]),
  code: row[1],
  event_name: row[2],
  points: Number(row[3]),
  goal: Number(row[4]),
  created_at: row[5],
  updated_at: row[6],
  icon_name: row[9],
}));

const translationRows = parseCopyBlock(sql, 'as_achievement_translations').map((row) => ({
  id: Number(row[0]),
  title: row[1],
  description: row[2],
  created_at: row[3],
  updated_at: row[4],
  locale: row[7] ?? 'en',
}));

const translationLinkRows = parseCopyBlock(sql, 'as_achievement_translations_achievement_links').map((row) => ({
  translation_id: Number(row[1]),
  achievement_id: Number(row[2]),
}));

const eventListRows = parseCopyBlock(sql, 'as_event_lists').map((row) => ({
  id: Number(row[0]),
  event_name: row[1],
  points: Number(row[2]),
  created_at: row[3],
  updated_at: row[4],
}));

const userAchievementRows = parseCopyBlock(sql, 'as_user_achievements').map((row) => ({
  id: Number(row[0]),
  userid: row[1],
  username: row[2],
  progress: Number(row[3]),
  achieved: row[4],
  achieved_at: row[5],
  created_at: row[6],
  updated_at: row[7],
}));

const userAchievementLinkRows = parseCopyBlock(sql, 'as_user_achievements_achievement_links').map((row) => ({
  user_achievement_id: Number(row[1]),
  achievement_id: Number(row[2]),
}));

const translationById = new Map(translationRows.map((row) => [row.id, row]));
const translationOutputRows = translationLinkRows.map((link) => {
  const translation = translationById.get(link.translation_id);
  if (!translation) {
    throw new Error(`Missing translation row for id ${link.translation_id}`);
  }

  return {
    id: translation.id,
    achievement_id: link.achievement_id,
    locale: translation.locale,
    title: translation.title,
    description: translation.description,
    created_at: translation.created_at,
    updated_at: translation.updated_at,
  };
});

const userAchievementById = new Map(userAchievementRows.map((row) => [row.id, row]));
const userAchievementOutputRows = userAchievementLinkRows.map((link) => {
  const userAchievement = userAchievementById.get(link.user_achievement_id);
  if (!userAchievement) {
    throw new Error(`Missing user achievement row for id ${link.user_achievement_id}`);
  }

  return {
    id: userAchievement.id,
    userid: userAchievement.userid,
    username: userAchievement.username,
    achievement_id: link.achievement_id,
    progress: userAchievement.progress,
    achieved: userAchievement.achieved,
    achieved_at: userAchievement.achieved_at,
    created_at: userAchievement.created_at,
    updated_at: userAchievement.updated_at,
  };
});

const output = `-- Generated from ../langgo_strapi4/database/backup/langgo_full.sql
-- Source date: 2026-05-10
-- Target schema placeholder: {{SCHEMA}}

BEGIN;

INSERT INTO {{SCHEMA}}.as_achievements
  (id, code, event_name, icon_name, points, goal, created_at, updated_at)
VALUES
${emitValues(achievementRows, (row) => [
  sqlNumber(row.id),
  sqlString(row.code),
  sqlString(row.event_name),
  sqlString(row.icon_name),
  sqlNumber(row.points),
  sqlNumber(row.goal),
  sqlString(row.created_at),
  sqlString(row.updated_at),
])}
ON CONFLICT (id) DO UPDATE
SET code = EXCLUDED.code,
    event_name = EXCLUDED.event_name,
    icon_name = EXCLUDED.icon_name,
    points = EXCLUDED.points,
    goal = EXCLUDED.goal,
    updated_at = EXCLUDED.updated_at;

INSERT INTO {{SCHEMA}}.as_achievement_translations
  (id, achievement_id, locale, title, description, created_at, updated_at)
VALUES
${emitValues(translationOutputRows, (row) => [
  sqlNumber(row.id),
  sqlNumber(row.achievement_id),
  sqlString(row.locale),
  sqlString(row.title),
  sqlString(row.description),
  sqlString(row.created_at),
  sqlString(row.updated_at),
])}
ON CONFLICT (id) DO UPDATE
SET achievement_id = EXCLUDED.achievement_id,
    locale = EXCLUDED.locale,
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    updated_at = EXCLUDED.updated_at;

INSERT INTO {{SCHEMA}}.as_event_lists
  (id, event_name, points, created_at, updated_at)
VALUES
${emitValues(eventListRows, (row) => [
  sqlNumber(row.id),
  sqlString(row.event_name),
  sqlNumber(row.points),
  sqlString(row.created_at),
  sqlString(row.updated_at),
])}
ON CONFLICT (id) DO UPDATE
SET event_name = EXCLUDED.event_name,
    points = EXCLUDED.points,
    updated_at = EXCLUDED.updated_at;

INSERT INTO {{SCHEMA}}.as_user_achievements
  (id, userid, username, achievement_id, progress, achieved, achieved_at, created_at, updated_at)
VALUES
${emitValues(userAchievementOutputRows, (row) => [
  sqlNumber(row.id),
  sqlString(row.userid),
  sqlString(row.username),
  sqlNumber(row.achievement_id),
  sqlNumber(row.progress),
  sqlBoolean(row.achieved),
  sqlString(row.achieved_at),
  sqlString(row.created_at),
  sqlString(row.updated_at),
])}
ON CONFLICT (id) DO UPDATE
SET userid = EXCLUDED.userid,
    username = EXCLUDED.username,
    achievement_id = EXCLUDED.achievement_id,
    progress = EXCLUDED.progress,
    achieved = EXCLUDED.achieved,
    achieved_at = EXCLUDED.achieved_at,
    updated_at = EXCLUDED.updated_at;

${setvalSql('as_achievements', achievementRows)}
${setvalSql('as_achievement_translations', translationOutputRows)}
${setvalSql('as_event_lists', eventListRows)}
${setvalSql('as_user_achievements', userAchievementOutputRows)}

COMMIT;
`;

await fs.writeFile(outputPath, output, 'utf8');

console.log(`Generated ${outputPath}`);
console.log(`Achievements: ${achievementRows.length}`);
console.log(`Translations: ${translationOutputRows.length}`);
console.log(`Event list rows: ${eventListRows.length}`);
console.log(`User achievements: ${userAchievementOutputRows.length}`);
