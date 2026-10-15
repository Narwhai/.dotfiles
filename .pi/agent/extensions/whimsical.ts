import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const messages = [
  // Short
  "Spice cycling...",
  "Sandwalking...",
  "Tracking wormsign...",
  "Adjusting the stillsuit...",
  "Sharpening the crysknife...",
  "Reading the spice...",
  "Huffin spice...",
  "Following the Golden Path...",
  "Sietch scouting...",
  "Fremen plotting...",
  "Arrakis dreaming...",
  "Peering into prescience...",
  "Dune drifting...",
  "Gettin in the tank...",
  "Huffin even more spice...",
  "Bene Gesserit training...",
  "Ghola awakening...",
  "Guild Navigator folding...",
  "Mentat calculating...",
  "Shai-Hulud communing...",
  "Water of Life drinking...",
  "Landsraad scheming...",
  "Thumper pounding...",
  "Spice harvesting...",
  "Prescience flowing...",
  "Arrakis calling...",
  "Stillness mastering...",
  "Sandworm riding...",

  // Long
  "Consulting the spice trance before the next move...",
  "Listening for wormsign beneath the dunes...",
  "Walking without rhythm across Arrakis...",
  "Seeking shelter in the sietch until the storm passes...",
  "Keeping the stillsuit sealed and the water sacred...",
  "Reading the future through a shimmer of spice...",
  "Sharpening the crysknife and steeling the nerve...",
  "Plotting the Golden Path one step at a time...",
  "Negotiating with the Imperium and its endless intrigue...",
  "Waiting for the sandworm to pass in perfect stillness...",
  "Letting the desert teach patience, discipline, and survival...",
  "Whispering with the Fremen about what comes next...",
  "Training with the Bene Gesserit and their forbidden knowledge...",
  "Awakening a Ghola from the genetic vats in the deep lab...",
  "Navigating through folded space on Guild Navigator wings...",
  "Swimming in the raw spice trance, unlimited prescience flooding in...",
  "Melding body and mind through Bene Gesserit disciplines...",
  "Tracing the patterns of the Golden Path across centuries...",
  "Communing with a sandworm beneath the dunes of Arrakis...",
  "Decoding ancient prophecies from the Orange Catholic Bible...",
  "Weaving political threads through the Houses of the Landsraad...",
  "Diving deep into spice meditation and the ancestral memories...",
  "Engineering the next link in a chain of controlled evolution...",
  "Witnessing a Guild Navigator's terrible, beautiful transformation...",
  "Unlocking the secrets the Bene Gesserit guard with their lives...",
  "Tracing a Ghola's awakening to a consciousness reborn...",
  "Dancing the delicate politics between Arrakis, Caladan, and the Throne...",
  "Drinking the Water of Life and touching prescient visions...",
];

function pickRandom(): string {
  return messages[Math.floor(Math.random() * messages.length)];
}

export default function(pi: ExtensionAPI) {
  pi.on("turn_start", async (_event, ctx) => {
    ctx.ui.setWorkingMessage(pickRandom());
  });

  pi.on("turn_end", async (_event, ctx) => {
    ctx.ui.setWorkingMessage(); // Reset for next time
  });
}
