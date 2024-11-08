import React, { useEffect, useState } from "react";
import axios from "axios";
import './LoginButton.css'
import 'reactjs-popup/dist/index.css';


const SPACE_DELIM = "%20";

const CLIENT_ID = "bd84d93076144a869d1990b8aa228cb9";
const SPOTIFY_AUTHORISE_ENDPOINT = 'https://accounts.spotify.com/authorize';
const REDIRECT_URL_AFTER_LOGIN = "http://localhost:3000/Callback";

const SCOPES = ["playlist-modify-public", "playlist-modify-private", "playlist-read-private", "user-read-private", "user-read-email"];
const SCOPES_URL_PARAM = SCOPES.join(SPACE_DELIM);



const handleLogin = () => {
    window.location = `${SPOTIFY_AUTHORISE_ENDPOINT}?client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URL_AFTER_LOGIN}&scope=${SCOPES_URL_PARAM}&response_type=token&show_dialogue=true`;
};


const USER_ENDPOINT = "https://api.spotify.com/v1/me";

const LogOutButton = () => {
  const [token, setToken] = useState("");
  const [data, setData] = useState({});

  useEffect(() => {
    if (localStorage.getItem("accessToken")) {
      setToken(localStorage.getItem("accessToken"));
    }
  }, []);

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

  return (
    <>
    {data?.images && data.images[0] ? <button class="button"><img src={data.images[0].url} height="80" width="80"></img></button> : null}
    </>
  );
};






export default LogOutButton