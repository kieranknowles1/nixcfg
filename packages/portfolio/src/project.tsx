import { JSX, VNode } from "preact";
import { IdTitle } from "./utils";

export type ProjectProps = IdTitle & {
  videoId: string
  links: {
    github: string,
    itchio: string,
  },
  summary: VNode<HTMLParagraphElement>,
  bullets: string[]
  feedback: {
    author: string,
    content: VNode<HTMLQuoteElement>,
    rating: number
  }
}

export default function Project(props: ProjectProps) {
  return <article id={props.id}>
    <h3>{props.title}</h3>
  </article>
}

//         <article id="blitzbox">
//             <h3>Blitzbox</h3>
//             <?php echo embedVideo('xMGoUh14qWc') ?>
//             <!-- TODO: Gallery -->
//             <div class="twopane">
//               <div>
//                 <?php echo projectLinks([
//                     'github' => 'https://github.com/kieranknowles1/csc8508-team-project',
//                     'itchio' => 'https://abarnett.itch.io/blitzbox',
//                 ]); ?>
//                 <p>
//                   A gravity manipulation boomer shooter built for the CSC8508 Team Project module by
//                   a team of eight. My work includes:
//                 </p>
//                 <ul>
//                   <li>Full PS5 support, including cross-platform multiplayer</li>
//                   <li>Multithreaded asset loading via a thread pool</li>
//                   <li>Controller input on all platforms</li>
//                   <li>Automatic mesh conversion during build, for an order of magnitude speedup</li>
//                   <li>TrueType font rendering via a texture atlas</li>
//                   <li>Memory leak detection using Valgrind</li>
//                   <li>As always, Linux support through SDL2</li>
//                 </ul>
//               </div>
//               <?php echo feedbackSection("Dr G Ushaw", 100, <<<HTML
//                 Absolutely excellent. A fully feature-complete game that plays well, looks great and is truly cross
//                 platform. Great to see good teamwork throughout the project with lots of individual efforts coming
//                 together in a consistent and well presented piece of work. Single player works very well with great
//                 use of bots, the online tech also very good, including multi-platform play. PS5 is very good, as is
//                 the editor.
//               HTML);?>
//             </div>
//         </article>
