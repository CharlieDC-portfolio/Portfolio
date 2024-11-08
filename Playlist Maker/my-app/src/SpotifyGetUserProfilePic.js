import React, { useEffect, useState } from "react";
import axios from "axios";

const USER_ENDPOINT = "https://api.spotify.com/v1/me";

const SpotifyGetUserProfilePic = () => {
  const [token, setToken] = useState("");
  const [data, setData] = useState({});

  useEffect(() => {
    if (localStorage.getItem("accessToken")) {
      setToken(localStorage.getItem("accessToken"));
    }
  }, []);

  const handleGetUserProfilePic = () => {
    axios
      .get(USER_ENDPOINT, {
        headers: {
          Authorization: "Bearer " + token,
        },
      })
      .then((response) => {
        setData(response.data);
      })
      .catch((error) => {
        console.log(error);
      });
  };

  return (
    <>
    <button onClick={handleGetUserProfilePic}>Get Profile Pic</button>
    {data?.images && data.images[0] ? <body><img src={data.images[0].url} height="80" width="80"></img></body> : null}
    </>
  );
};

export default SpotifyGetUserProfilePic;