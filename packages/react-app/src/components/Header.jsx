import { PageHeader } from "antd";
import React from "react";

// displays a page header

export default function Header() {
  return (
    <a href="https://github.com/AnastasiaMenshikova/challenge-1-decentralized-staking" /*target="_blank" rel="noopener noreferrer"*/>
      <PageHeader
        title="🏗 scaffold-eth"
        subTitle="Demo staking app"
        style={{ cursor: "pointer" }}
      />
    </a>
  );
}
