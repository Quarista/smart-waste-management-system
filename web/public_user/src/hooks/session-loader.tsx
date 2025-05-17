import { useEffect, useState } from "react";
import { motion, AnimatePresence, useAnimationControls } from "framer-motion";

interface SessionLoaderProps {
  duration?: number;
  imageUrl?: string;
  onLoadComplete?: () => void;
}
/**
 * SessionLoader component that displays a loading animation with a logo and a gradient background.
 * The logo scales and fades out after a specified duration, and the background has a gradient effect.
 *
 * @param {number} duration - Duration of the loading animation in milliseconds (default: 5000).
 * @param {string} imageUrl - URL of the logo image to display (default: "https://i.ibb.co/rfGjqgLD/Logo-Ai-4-B-W.png").
 * @param {function} onLoadComplete - Callback function to be called when the loading animation completes.
 */

export const SessionLoader = ({
  duration = 5000,
  imageUrl = "https://i.ibb.co/rfGjqgLD/Logo-Ai-4-B-W.png",
  onLoadComplete,
}: SessionLoaderProps) => {
  const [isVisible, setIsVisible] = useState(true);
  const [, setProgress] = useState(0);
  const [sessionHash] = useState(() => {
    // Generate the random hash once per session using a useState initializer function
    return Array.from({ length: 16 }, () =>
      Math.floor(Math.random() * 16).toString(16)
    ).join("");
  });
  const logoControls = useAnimationControls();

  useEffect(() => {
    let startTime: number;
    let animationFrame: number;

    const animate = (timestamp: number) => {
      if (!startTime) startTime = timestamp;
      const elapsed = timestamp - startTime;
      const newProgress = Math.min(100, (elapsed / duration) * 100);

      setProgress(newProgress);

      if (elapsed < duration) {
        animationFrame = requestAnimationFrame(animate);
      } else {
        logoControls
          .start({
            scale: [1, 1.2, 0],
            opacity: [1, 1, 0],
            transition: { duration: 0.8 },
          })
          .then(() => {
            setIsVisible(false);
            if (onLoadComplete) onLoadComplete();
          });
      }
    };

    animationFrame = requestAnimationFrame(animate);

    return () => {
      cancelAnimationFrame(animationFrame);
    };
  }, [duration, onLoadComplete, logoControls]);

  return (
    <>
      <AnimatePresence>
        {isVisible && (
          <motion.div
            className="fixed inset-0 flex items-center justify-center overflow-hidden z-20"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.8 }}
          >
            <motion.div
              className="absolute inset-0 bg-gradient-to-br dark:from-zinc-900 dark:to-black from-white to-indigo-50"
              transition={{
                duration: 15,
                repeat: Infinity,
                ease: "easeInOut",
                times: [0, 0.5, 1],
              }}
            />

            <div className="relative flex flex-col items-center justify-center z-10">
              <motion.div
                className="relative"
                animate={logoControls}
                style={{
                  filter: "drop-shadow(0 0 10px rgba(255,255,255,0.5))",
                }}
              >
                <motion.img
                  src={imageUrl}
                  alt="Loading"
                  className="w-48 h-auto invert-0 dark:invert select-none pointer-events-none z-20 relative"
                  animate={{
                    scale: [0.95, 1.05, 0.95],
                    rotate: [0, 2, -2, 0],
                  }}
                  transition={{
                    duration: 4,
                    repeat: Infinity,
                    ease: "easeInOut",
                  }}
                />
              </motion.div>
            </div>
            <motion.span
              className="z-50 absolute bottom-0 pb-4 text-black/40 dark:text-white/40 font-mono text-xs w-full text-center select-none pointer-events-none"
              animate={{ opacity: [0.4, 0.8, 0.4] }}
              transition={{ duration: 4, repeat: 10, ease: "easeInOut" }}
            >
              {sessionHash}
            </motion.span>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
};
