const fs = require('fs');
const GUILD_ID = process.env.GUILD_ID;
const ROLE_ID = process.env.ROLE_ID;
const TOKEN = process.env.DISCORD_BOT_TOKEN;

async function fetchAllMembers(){
  let members = [];
  let after = '0';
  while (true){
    const res = await fetch(`https://discord.com/api/v10/guilds/${GUILD_ID}/members?limit=1000&after=${after}`, {
      headers: { Authorization: `Bot ${TOKEN}` }
    });
    if (!res.ok){
      const text = await res.text();
      throw new Error(`Discord API error ${res.status}: ${text}`);
    }
    const batch = await res.json();
    if (batch.length === 0) break;
    members = members.concat(batch);
    after = batch[batch.length - 1].user.id;
    if (batch.length < 1000) break;
  }
  return members;
}

function avatarUrl(user){
  if (user.avatar){
    const ext = user.avatar.startsWith('a_') ? 'gif' : 'png';
    return `https://cdn.discordapp.com/avatars/${user.id}/${user.avatar}.${ext}?size=64`;
  }
  const index = Number(BigInt(user.id) >> 22n) % 6;
  return `https://cdn.discordapp.com/embed/avatars/${index}.png`;
}

(async () => {
  const members = await fetchAllMembers();
  const withRole = members
    .filter(m => m.roles.includes(ROLE_ID))
    .map(m => ({
      id: m.user.id,
      username: m.user.username,
      globalName: m.user.global_name || null,
      nick: m.nick || null,
      avatar: avatarUrl(m.user),
    }));
  const output = { updatedAt: new Date().toISOString(), members: withRole };
  fs.writeFileSync('discord-members.json', JSON.stringify(output, null, 2));
  console.log(`Wrote ${withRole.length} members with role ${ROLE_ID}`);
})().catch(err => {
  console.error(err);
  process.exit(1);
});
