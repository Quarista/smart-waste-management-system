"use client";

import { motion, stagger, useAnimate, useInView } from "framer-motion";
import { useEffect } from "react";

export const TypewriterEffect = ({
  words,
  totalDuration = 5, // Total duration in seconds
}: {
  words: {
    text: string;
  }[];
  totalDuration?: number;
}) => {
  const wordsArray = words.map((word) => ({
    ...word,
    text: word.text.split(""),
  }));

  const totalCharacters = wordsArray.reduce(
    (acc, word) => acc + word.text.length,
    0
  );
  const charDuration = totalDuration / totalCharacters; // Duration per character

  const [scope, animate] = useAnimate();
  const isInView = useInView(scope);

  useEffect(() => {
    if (isInView) {
      animate(
        "span",
        { opacity: 1 },
        { duration: charDuration, delay: stagger(charDuration), ease: "easeInOut" }
      );
    }
  }, [isInView]);

  return (
    <div ref={scope}>
      {wordsArray.map((word, idx) => (
        <div key={`word-${idx}`} className="inline-block">
          {word.text.map((char, index) => (
            <motion.span
              key={`char-${index}`}
              initial={{ opacity: 0 }}
              className="opacity-0"
            >
              {char}
            </motion.span>
          ))}
          &nbsp;
        </div>
      ))}
      <motion.span
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{
          duration: 0.8,
          repeat: Infinity,
          repeatType: "reverse",
        }}
        className="inline-block w-[4px] h-4 bg-blue-500"
      ></motion.span>
    </div>
  );
};
