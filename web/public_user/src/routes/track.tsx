import { useState, useEffect } from "react";
import { GoogleMap, LoadScript, MarkerF } from "@react-google-maps/api";
import {
  IconMapPinFilled,
  IconAlertTriangleFilled,
  IconLocationFilled,
  IconTemperature,
  IconUmbrellaFilled,
  IconTrash,
  IconGalaxy,
} from "@tabler/icons-react";
import { motion } from "framer-motion";
import { collection, onSnapshot } from "firebase/firestore";
import { db } from "@/backend/firebase";

import { Drawer, DrawerContent, DrawerTrigger } from "@/components/ui/drawer";

const containerStyle = {
  width: "100%",
  height: "400px",
};

const center = {
  lat: 7.003106,
  lng: 79.967045,
};

const customLocations = [{ lat: 79.90275129828092, lng: 6.795901053000571 }];

// Helper function to determine status color
const getStatusColor = (percentage: number) => {
  if (percentage >= 90) return "bg-red-500";
  if (percentage >= 60) return "bg-amber-500";
  return "bg-green-600";
};

// Helper function to determine gas level color
const getGasLevelColor = (level: number) => {
  if (level >= 400) return "bg-purple-800";
  if (level >= 200) return "bg-orange-500";
  if (level >= 50) return "bg-amber-500";
  return "bg-teal-500"; // Low Gas
};

export default function TrackingPortal() {
  const [currentLocation, setCurrentLocation] = useState(center);
  const [showPins, setShowPins] = useState(false);
  const [binResults, setBinResults] = useState<
    { id: string; [key: string]: any }[]
  >([]);
  const [, setSelectedBin] = useState<{
    id: string;
    [key: string]: any;
  } | null>(null);
  const [loading, setLoading] = useState(true);
  const [lastUpdated, setLastUpdated] = useState<Date>(new Date());

  // Replace fetchBins with a real-time listener
  useEffect(() => {
    navigator.geolocation.getCurrentPosition((position) => {
      setCurrentLocation({
        lat: position.coords.latitude,
        lng: position.coords.longitude,
      });
    });

    const timer = setTimeout(() => {
      setShowPins(true);
      clearTimeout(timer);
    }, 3000);

    // Set up real-time listener for Firestore collection
    const binsCollection = collection(db, "Dustbins");
    const unsubscribe = onSnapshot(
      binsCollection,
      (snapshot) => {
        const binsData = snapshot.docs.map((doc) => ({
          id: doc.id,
          name: doc.id,
          ...doc.data(),
        }));
        setBinResults(binsData);
        setLoading(false);
        setLastUpdated(new Date());
      },
      (error) => {
        console.error("Error setting up real-time listener:", error);
        setLoading(false);
      }
    );

    // Cleanup function
    return () => {
      clearTimeout(timer);
      unsubscribe(); // Unsubscribe from the listener when component unmounts
    };
  }, []);

  // Format the last updated time
  const formatLastUpdated = (date: Date) => {
    return new Intl.DateTimeFormat('en-US', {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: true
    }).format(date);
  };

  return (
    <motion.div
      initial={{ opacity: 0.0, y: 40 }}
      whileInView={{ opacity: 1, y: 0 }}
      transition={{
        delay: 0.5,
        duration: 1,
        ease: "easeInOut",
      }}
    >
      <div className="max-w-screen min-h-[100vh] flex flex-col-reverse xl:flex-row gap-[5%] items-center justify-center overflow-x-hidden">
        <div>
          {!showPins && (
            <div>
              {currentLocation.lat !== center.lat ||
              currentLocation.lng !== center.lng ? (
                <button
                  className="my-4 p-4 bg-zinc-200 dark:bg-zinc-700 text-black dark:text-white rounded flex flex-row gap-2 items-center"
                  disabled
                >
                  <div className="flex items-center gap-2">
                    <svg
                      className="animate-spin h-5 w-5 text-black dark:text-white"
                      xmlns="http://www.w3.org/2000/svg"
                      fill="none"
                      viewBox="0 0 24 24"
                    >
                      <circle
                        className="opacity-25"
                        cx="12"
                        cy="12"
                        r="10"
                        stroke="currentColor"
                        strokeWidth="4"
                      ></circle>
                      <path
                        className="opacity-75"
                        fill="currentColor"
                        d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"
                      ></path>
                    </svg>
                    Filtering...
                  </div>
                </button>
              ) : (
                <button
                  className="my-4 p-3 bg-amber-500 text-white rounded flex flex-row gap-2 items-center"
                  disabled
                >
                  <IconAlertTriangleFilled size={20} /> Location Access Denied
                </button>
              )}
            </div>
          )}
          {showPins && (
            <motion.div
              initial={{ opacity: 0.0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{
                delay: 0.5,
                duration: 1,
                ease: "circInOut",
              }}
            >
              <div className="rounded-xl border border-zinc-300 shadow-sm dark:border-zinc-800 my-8">
                <div className="p-4 dark:text-white text-black bg-zinc-50 border-b border-zinc-300 dark:border-zinc-800 dark:bg-zinc-950 rounded-t-xl flex justify-between items-center">
                  <h2 className="text-xl font-semibold">Results</h2>
                  <div className="text-xs text-gray-500 dark:text-gray-400 flex items-center">
                    <span>Last updated: {formatLastUpdated(lastUpdated)}</span>
                    {loading && (
                      <svg
                        className="animate-spin h-4 w-4 ml-2 text-black dark:text-white"
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 24 24"
                      >
                        <circle
                          className="opacity-25"
                          cx="12"
                          cy="12"
                          r="10"
                          stroke="currentColor"
                          strokeWidth="4"
                        ></circle>
                        <path
                          className="opacity-75"
                          fill="currentColor"
                          d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"
                        ></path>
                      </svg>
                    )}
                  </div>
                </div>
                <div className="max-h-[500px] overflow-y-auto rounded-xl">
                  {loading ? (
                    <div className="flex items-center justify-center p-8">
                      <svg
                        className="animate-spin h-6 w-6 text-black dark:text-white"
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 24 24"
                      >
                        <circle
                          className="opacity-25"
                          cx="12"
                          cy="12"
                          r="10"
                          stroke="currentColor"
                          strokeWidth="4"
                        ></circle>
                        <path
                          className="opacity-75"
                          fill="currentColor"
                          d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"
                        ></path>
                      </svg>
                    </div>
                  ) : (
                    binResults.map((bin) => (
                      <Drawer key={bin.id}>
                        <DrawerTrigger asChild>
                          <div
                            className="p-4 bg-zinc-50 dark:bg-zinc-950 border-b border-zinc-200 dark:border-zinc-800 flex items-center gap-4 cursor-pointer hover:bg-gray-100 dark:hover:bg-zinc-800 transition-all"
                            onClick={() => setSelectedBin(bin)}
                          >
                            <img
                              src={
                                bin.imageUrl ||
                                "https://th.bing.com/th/id/OIP.VGl-1x_jqNqQms5kaeUYEgHaHa?rs=1&pid=ImgDetMain"
                              }
                              alt={bin.name}
                              className="w-24 h-24 object-cover rounded-lg"
                              onError={(e) => {
                                (e.target as HTMLImageElement).src =
                                  "https://th.bing.com/th/id/OIP.VGl-1x_jqNqQms5kaeUYEgHaHa?rs=1&pid=ImgDetMain";
                              }}
                            />
                            <div className="flex-1">
                              <h3 className="text-lg font-medium text-black dark:text-white">
                                {bin.name}
                              </h3>
                              <span className="text-gray-500 dark:text-zinc-100">
                                {bin.nameLocation || "N/A"}
                              </span>
                              <div className="flex gap-2 mt-2">
                                <span
                                  className={`text-xs px-2 py-1 rounded-full text-white ${getStatusColor(
                                    (bin.fillLevel / bin.capacity) * 100
                                  )}`}
                                >
                                  {(
                                    (bin.fillLevel / bin.capacity) *
                                    100
                                  ).toFixed(0)}
                                  % Full
                                </span>
                                <span
                                  className={`text-xs px-2 py-1 rounded-full text-white ${getGasLevelColor(
                                    bin.gasLevel
                                  )}`}
                                >
                                  {bin.gasLevel >= 400
                                    ? "Hazardous Gas"
                                    : bin.gasLevel >= 200
                                    ? "Strong Gas"
                                    : bin.gasLevel >= 50
                                    ? "Mild Gas"
                                    : "Minimal Gas"}
                                </span>
                              </div>
                            </div>
                            <div className="text-gray-400">
                              <IconMapPinFilled size={20} />
                            </div>
                          </div>
                        </DrawerTrigger>
                        <DrawerContent>
                          <div className="container mx-auto p-4">
                            <div className="w-full flex flex-col md:flex-row justify-start items-center gap-4 border p-4 rounded-xl bg-zinc-100 dark:bg-black/10 dark:border-zinc-700 border-zinc-300">
                              <div className="w-full md:w-1/4">
                                <img
                                  src={
                                    bin.imageUrl ||
                                    "https://th.bing.com/th/id/OIP.VGl-1x_jqNqQms5kaeUYEgHaHa?rs=1&pid=ImgDetMain"
                                  }
                                  alt={bin.name}
                                  className="w-auto h-64 rounded-lg object-cover border dark:border-zinc-700 border-zinc-300"
                                  onError={(e) => {
                                    (e.target as HTMLImageElement).src =
                                      "https://th.bing.com/th/id/OIP.VGl-1x_jqNqQms5kaeUYEgHaHa?rs=1&pid=ImgDetMain";
                                  }}
                                />
                              </div>
                              <div className="w-full md:w-3/4 space-y-4 border lg:dark:border-zinc-700 dark:border-none border-zinc-300 p-4 rounded-xl bg-white dark:bg-black/10">
                                <span className="text-2xl font-bold mb-1 text-zinc-900 dark:text-zinc-300">
                                  {bin.name}
                                </span>
                                <div>
                                  <span className="dark:text-white text-zinc-700">
                                    {bin.location || "N/A"}
                                  </span>
                                </div>
                                <div>
                                  <div className="grid lg:flex grid-cols-1 gap-2 my-2">
                                    <div
                                      className={`px-3 py-2 rounded-lg text-white flex items-center gap-2 max-w-fit ${getStatusColor(
                                        (bin.fillLevel / bin.capacity) * 100
                                      )}`}
                                    >
                                      <IconTrash size={16} />
                                      <span className="text-sm font-medium">
                                        {(
                                          (bin.fillLevel / bin.capacity) *
                                          100
                                        ).toFixed(0)}
                                        % Full
                                      </span>
                                    </div>
                                    <div
                                      className={`px-3 py-2 rounded-lg text-white flex items-center gap-2 max-w-fit ${getGasLevelColor(
                                        bin.gasLevel
                                      )}`}
                                    >
                                      <IconGalaxy size={16} />
                                      <span className="text-sm font-medium">
                                        {bin.gasLevel} ppm
                                      </span>
                                    </div>
                                    <div
                                      className={`px-3 py-2 rounded-lg text-white flex items-center gap-2 max-w-fit ${
                                        bin.temperature >= 40
                                          ? "bg-red-500"
                                          : bin.temperature >= 36
                                          ? "bg-orange-500"
                                          : bin.temperature >= 20
                                          ? "bg-amber-500"
                                          : "bg-blue-500"
                                      }`}
                                    >
                                      <IconTemperature size={18} />
                                      <span className="text-sm font-medium">
                                        {bin.temperature}°C
                                      </span>
                                    </div>
                                    <div className="px-3 py-2 rounded-lg text-white flex items-center gap-2 max-w-fit bg-cyan-500">
                                      <IconUmbrellaFilled size={16} />
                                      <span className="text-sm font-medium">
                                        {bin.precipitation}%
                                      </span>
                                    </div>
                                  </div>
                                </div>
                                <div className="mt-6 flex justify-end">
                                  <a
                                    href={`https://www.google.com/maps?q=${
                                      bin.location?.lat ||
                                      customLocations[0].lat
                                    },${
                                      bin.location?.lng ||
                                      customLocations[0].lng
                                    }`}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="px-4 py-2 bg-sky-500 dark:bg-sky-700 text-white rounded hover:bg-sky-600 transition flex flex-row"
                                  >
                                    View Location{" "}
                                    <IconLocationFilled className="flex w-4 ml-2" />
                                  </a>
                                </div>
                              </div>
                            </div>
                          </div>
                        </DrawerContent>
                      </Drawer>
                    ))
                  )}
                </div>
              </div>
            </motion.div>
          )}
        </div>
        {currentLocation.lat !== center.lat ||
        currentLocation.lng !== center.lng ? (
          <div className="text-black dark:text-white w-full xl:w-1/2 px-4 md:px-8 pt-48 xl:pt-0">
            <LoadScript
              googleMapsApiKey={import.meta.env.VITE_GOOGLE_MAPS_API_KEY}
            >
              <GoogleMap
                mapContainerStyle={containerStyle}
                center={currentLocation}
                zoom={20}
                options={{
                  zoomControl: true,
                  mapTypeControl: true,
                  scaleControl: true,
                  streetViewControl: true,
                  rotateControl: true,
                  fullscreenControl: true,
                  disableDefaultUI: false,
                  maxZoom: 20,
                }}
              >
                <MarkerF position={currentLocation} />
                {showPins &&
                  customLocations.map((location, index) => (
                    <MarkerF key={index} position={location} />
                  ))}
              </GoogleMap>
            </LoadScript>
          </div>
        ) : null}
      </div>
    </motion.div>
  );
}
